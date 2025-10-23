// Script to create test notes in Firebase
// Run with: node create-test-notes.js

import { initializeApp } from 'firebase/app';
import { getDatabase, ref, set } from 'firebase/database';

const firebaseConfig = {
  apiKey: "AIzaSyAeAEb7D8jsXskzTdqpHZljMly7xNyowlY",
  authDomain: "scrabble-6b9ff.firebaseapp.com",
  databaseURL: "https://scrabble-6b9ff-default-rtdb.firebaseio.com",
  projectId: "scrabble-6b9ff",
  storageBucket: "scrabble-6b9ff.firebasestorage.app",
  messagingSenderId: "900015312245",
  appId: "1:900015312245:web:fb317c8f117abb8b39573c"
};

const app = initializeApp(firebaseConfig);
const database = getDatabase(app);

// Simple base64 encoded test image (small colored square)
const testImage = "iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAAFUlEQVR42mP8z8BQz0AEYBxVSF+FABJADveWkH6oAAAAAElFTkSuQmCC";

// Create test notes
const testNotes = [
  {
    recipient: "Sarah Johnson",
    sender: "Mike Chen",
    templateTheme: "watercolor",
  },
  {
    recipient: "The Amazing Team",
    sender: "Emily Rodriguez",
    templateTheme: "heartBorder",
  },
  {
    recipient: "Dr. Smith",
    sender: "John Williams",
    templateTheme: "confetti",
  },
  {
    recipient: "Mom & Dad",
    sender: "Jennifer Lee",
    templateTheme: "floral",
  },
  {
    recipient: "Best Friend Emma",
    sender: "Alex Thompson",
    templateTheme: "stickyNote",
  }
];

async function createTestNotes() {
  console.log('Creating test notes in Firebase...\n');

  for (let i = 0; i < testNotes.length; i++) {
    const note = testNotes[i];
    const sessionId = `test-${Date.now()}-${i}`;
    const timestamp = Date.now() - (i * 60000); // Space them out by 1 minute

    const session = {
      sessionId,
      status: 'ready_for_display', // Ready to be shown
      createdAt: timestamp,
      expiresAt: timestamp + 3600000, // 1 hour from creation
      iPad_input: {
        recipient: note.recipient,
        sender: note.sender,
        drawingImage: testImage,
        templateTheme: note.templateTheme,
      }
    };

    await set(ref(database, `sessions/${sessionId}`), session);
    console.log(`✅ Created note from ${note.sender} to ${note.recipient}`);
  }

  console.log('\n🎉 All test notes created successfully!');
  console.log('\nYou should now see:');
  console.log('- 5 notes in the Host Panel dashboard');
  console.log('- Notes cycling on the Display (localhost:3000)');
  console.log('- Total counter showing "5 Thank You Notes"');

  process.exit(0);
}

createTestNotes().catch((error) => {
  console.error('Error creating test notes:', error);
  process.exit(1);
});
