import { useState, useEffect, useRef } from 'react';
import { useParams, BrowserRouter, Routes, Route } from 'react-router-dom';
import { database } from './firebase';
import { ref, set } from 'firebase/database';
import './App.css';

function PhotoUploadPage() {
  const { sessionId } = useParams();
  const [photo, setPhoto] = useState(null);
  const [preview, setPreview] = useState(null);
  const [uploading, setUploading] = useState(false);
  const [uploadProgress, setUploadProgress] = useState(0);
  const [success, setSuccess] = useState(false);
  const fileInputRef = useRef(null);
  const videoRef = useRef(null);
  const [useCamera, setUseCamera] = useState(false);
  const [stream, setStream] = useState(null);
  const [autoClickTriggered, setAutoClickTriggered] = useState(false);

  // Auto-trigger file picker when page loads
  useEffect(() => {
    if (!autoClickTriggered && fileInputRef.current) {
      // Small delay to ensure DOM is ready
      const timer = setTimeout(() => {
        fileInputRef.current?.click();
        setAutoClickTriggered(true);
      }, 300);
      return () => clearTimeout(timer);
    }
  }, [autoClickTriggered]);

  useEffect(() => {
    return () => {
      // Cleanup camera stream
      if (stream) {
        stream.getTracks().forEach(track => track.stop());
      }
    };
  }, [stream]);

  const handleFileSelect = (e) => {
    const file = e.target.files[0];
    if (file) {
      // Resize and compress image
      resizeAndCompressImage(file, (compressedBlob) => {
        setPhoto(compressedBlob);
        const reader = new FileReader();
        reader.onloadend = () => {
          setPreview(reader.result);
        };
        reader.readAsDataURL(compressedBlob);
      });
    }
  };

  const resizeAndCompressImage = (file, callback) => {
    const reader = new FileReader();
    reader.onload = (e) => {
      const img = new Image();
      img.onload = () => {
        const canvas = document.createElement('canvas');
        const MAX_SIZE = 400; // Maximum width/height

        let width = img.width;
        let height = img.height;

        if (width > height) {
          if (width > MAX_SIZE) {
            height *= MAX_SIZE / width;
            width = MAX_SIZE;
          }
        } else {
          if (height > MAX_SIZE) {
            width *= MAX_SIZE / height;
            height = MAX_SIZE;
          }
        }

        canvas.width = width;
        canvas.height = height;
        const ctx = canvas.getContext('2d');
        ctx.drawImage(img, 0, 0, width, height);

        canvas.toBlob((blob) => {
          callback(blob);
        }, 'image/jpeg', 0.8); // 80% quality
      };
      img.src = e.target.result;
    };
    reader.readAsDataURL(file);
  };

  const startCamera = async () => {
    try {
      const mediaStream = await navigator.mediaDevices.getUserMedia({
        video: { facingMode: 'environment' }
      });
      setStream(mediaStream);
      if (videoRef.current) {
        videoRef.current.srcObject = mediaStream;
      }
      setUseCamera(true);
    } catch (err) {
      alert('Unable to access camera. Please use file upload instead.');
      console.error('Camera error:', err);
    }
  };

  const capturePhoto = () => {
    const video = videoRef.current;
    const canvas = document.createElement('canvas');

    // Resize to max 400px
    const MAX_SIZE = 400;
    let width = video.videoWidth;
    let height = video.videoHeight;

    if (width > height) {
      if (width > MAX_SIZE) {
        height *= MAX_SIZE / width;
        width = MAX_SIZE;
      }
    } else {
      if (height > MAX_SIZE) {
        width *= MAX_SIZE / height;
        height = MAX_SIZE;
      }
    }

    canvas.width = width;
    canvas.height = height;
    const ctx = canvas.getContext('2d');
    ctx.drawImage(video, 0, 0, width, height);

    canvas.toBlob((blob) => {
      if (blob) {
        setPhoto(blob);
        setPreview(canvas.toDataURL('image/jpeg', 0.8));
        setUseCamera(false);
        if (stream) {
          stream.getTracks().forEach(track => track.stop());
        }
      }
    }, 'image/jpeg', 0.8);
  };

  const uploadPhoto = async () => {
    if (!photo || !sessionId) return;

    setUploading(true);
    setUploadProgress(0);

    try {
      // Simulate progress during file reading
      setUploadProgress(20);

      // Convert to base64
      const reader = new FileReader();
      reader.onloadend = async () => {
        setUploadProgress(50);
        const base64String = reader.result.split(',')[1];

        setUploadProgress(70);
        // Store in Firebase under session's photos
        const photoRef = ref(database, `photos/${sessionId}`);
        await set(photoRef, {
          imageData: base64String,
          uploadedAt: Date.now()
        });

        setUploadProgress(100);

        // Small delay to show 100% before success screen
        setTimeout(() => {
          setSuccess(true);
        }, 300);
      };
      reader.readAsDataURL(photo);
    } catch (error) {
      alert('Upload failed. Please try again.');
      console.error('Upload error:', error);
      setUploadProgress(0);
    } finally {
      setUploading(false);
    }
  };

  if (!sessionId) {
    return (
      <div className="container error">
        <h1>❌ Invalid Link</h1>
        <p>Please scan the QR code again from the iPad.</p>
      </div>
    );
  }

  if (success) {
    return (
      <div className="container success">
        <div className="success-animation">
          <div className="checkmark-circle">
            <svg className="checkmark" viewBox="0 0 52 52">
              <circle className="checkmark-circle-outline" cx="26" cy="26" r="25" fill="none"/>
              <path className="checkmark-check" fill="none" d="M14.1 27.2l7.1 7.2 16.7-16.8"/>
            </svg>
          </div>
        </div>
        <h1>Photo Uploaded!</h1>
        <p>Your photo has been added to the note.</p>
        <p className="subtitle">You can close this window now.</p>
      </div>
    );
  }

  return (
    <div className="container">
      <div className="header">
        <h1>📸 Add a Photo</h1>
        <p>Take or upload a photo for your thank you note</p>
      </div>

      {!preview && !useCamera && (
        <div className="upload-options">
          <button className="btn btn-primary" onClick={() => fileInputRef.current?.click()}>
            📁 Choose from Gallery
          </button>
          <button className="btn btn-secondary" onClick={startCamera}>
            📷 Take a Photo
          </button>
          <input
            ref={fileInputRef}
            type="file"
            accept="image/*"
            onChange={handleFileSelect}
            style={{ display: 'none' }}
          />
        </div>
      )}

      {useCamera && (
        <div className="camera-container">
          <video
            ref={videoRef}
            autoPlay
            playsInline
            className="camera-preview"
          />
          <div className="camera-controls">
            <button className="btn btn-primary" onClick={capturePhoto}>
              📸 Capture
            </button>
            <button className="btn btn-secondary" onClick={() => {
              setUseCamera(false);
              if (stream) {
                stream.getTracks().forEach(track => track.stop());
              }
            }}>
              Cancel
            </button>
          </div>
        </div>
      )}

      {preview && !useCamera && (
        <div className="preview-container">
          <img src={preview} alt="Preview" className="preview-image" />

          {uploading && (
            <div className="upload-progress">
              <div className="progress-bar-container">
                <div
                  className="progress-bar-fill"
                  style={{ width: `${uploadProgress}%` }}
                />
              </div>
              <p className="progress-text">{uploadProgress}%</p>
            </div>
          )}

          <div className="preview-controls">
            <button
              className="btn btn-secondary"
              onClick={() => {
                setPhoto(null);
                setPreview(null);
              }}
              disabled={uploading}
            >
              ← Retake
            </button>
            <button
              className="btn btn-primary"
              onClick={uploadPhoto}
              disabled={uploading}
            >
              {uploading ? '⏳ Uploading...' : '✅ Use This Photo'}
            </button>
          </div>
        </div>
      )}
    </div>
  );
}

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/upload/:sessionId" element={<PhotoUploadPage />} />
        <Route path="*" element={
          <div className="container error">
            <h1>📸 Photo Upload</h1>
            <p>Please scan the QR code from the iPad to continue.</p>
          </div>
        } />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
