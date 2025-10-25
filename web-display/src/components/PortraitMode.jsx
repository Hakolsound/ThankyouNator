import React, { useEffect, useState, useRef, useMemo, useCallback } from 'react';

const PortraitMode = ({
  notes,
  displayDuration = 12000,
  scrollSpeed = 'medium',
  zoomDuration = 8000,
  cardsPerRow = 3,
  focusFrequency = 'normal',
  branding = {
    backgroundType: 'gradient',
    backgroundColor: '#f0f0f0',
    gradientStart: '#faf5ff',
    gradientEnd: '#fce7f3',
    gradientAngle: 135,
    backgroundImage: '',
    headerColorStart: '#a855f7',
    headerColorEnd: '#ec4899',
    headerGradientAngle: 90,
    headerFont: 'system-ui',
    headerPadding: 'normal',
    headerFontSize: 'native'
  }
}) => {
  const [scrollPosition, setScrollPosition] = useState(0);
  const [focusedIndex, setFocusedIndex] = useState(null);
  const [focusedRotation, setFocusedRotation] = useState(0);
  const [isExiting, setIsExiting] = useState(false);
  const containerRef = useRef(null);
  const gridRef = useRef(null);
  const animationFrameRef = useRef(null);
  const lastScrollTimeRef = useRef(Date.now());
  const lastRotationRef = useRef(Date.now());

  // Fixed layout grid with 60 card slots
  const TOTAL_CARDS = 60;

  // Generate sporadic layout with spacers for visual interest
  const layoutPattern = useMemo(() => {
    const pattern = [];
    const sizeWeights = {
      '1x1': 0.80,    // 80% - most common
      '2x3': 0.20     // 20% - medium emphasis
    };

    let currentColumn = 0;
    let slotIndex = 0;

    // Generate 60 cards with sporadic placement using spacers
    while (slotIndex < TOTAL_CARDS) {
      const rand = Math.random();
      let size, colSpan;

      // Randomly pick size
      if (rand < sizeWeights['1x1']) {
        size = '1x1';
        colSpan = 1;
      } else {
        size = '2x3';
        colSpan = 2;
      }

      // Add spacer occasionally for sporadic look (25% chance for more shuffled layout)
      if (Math.random() < 0.25 && currentColumn < cardsPerRow - 1) {
        pattern.push({ id: `spacer-${slotIndex}`, size: 'spacer', isSpacer: true });
        currentColumn++;
      }

      // If card doesn't fit in current row, add spacers to fill row
      if (currentColumn + colSpan > cardsPerRow) {
        while (currentColumn < cardsPerRow) {
          pattern.push({ id: `spacer-fill-${slotIndex}-${currentColumn}`, size: 'spacer', isSpacer: true });
          currentColumn++;
        }
        currentColumn = 0;
      }

      // Add the card
      pattern.push({ id: `slot-${slotIndex}`, size, colSpan });
      currentColumn += colSpan;

      // Reset column counter when row is complete
      if (currentColumn >= cardsPerRow) {
        currentColumn = 0;
      }

      slotIndex++;
    }

    console.log('[PortraitMode] Generated sporadic layout:', {
      total: pattern.length,
      cards: slotIndex,
      spacers: pattern.filter(p => p.isSpacer).length,
      sizes: pattern.filter(p => !p.isSpacer).reduce((acc, p) => ({ ...acc, [p.size]: (acc[p.size] || 0) + 1 }), {})
    });

    return pattern;
  }, [cardsPerRow]); // Regenerate when cardsPerRow changes

  // Map notes to card slots - content only, not positions (skip spacers)
  const [cardContent, setCardContent] = useState({});

  // Initialize card content when layoutPattern or notes change
  useEffect(() => {
    if (notes.length === 0) {
      setCardContent({});
      return;
    }

    const content = {};
    const cardSlots = layoutPattern.filter(slot => !slot.isSpacer);
    cardSlots.forEach((slot, idx) => {
      content[slot.id] = notes[idx % notes.length];
    });
    setCardContent(content);
  }, [notes, layoutPattern]);

  // Track which cards are off-screen for content rotation
  const getVisibleRange = useCallback(() => {
    const viewportHeight = window.innerHeight;
    const rowHeight = 200; // Approximate
    const initialOffset = viewportHeight;
    const actualScroll = scrollPosition - initialOffset;

    const topBound = actualScroll - rowHeight * 2;
    const bottomBound = actualScroll + viewportHeight + rowHeight * 2;

    return { topBound, bottomBound };
  }, [scrollPosition]);

  // Rotate content in off-screen cards
  useEffect(() => {
    if (notes.length === 0) return;

    const rotationInterval = displayDuration || 12000;
    const now = Date.now();

    if (now - lastRotationRef.current < rotationInterval) return;

    const { topBound, bottomBound } = getVisibleRange();
    const rowHeight = 200;

    // Find off-screen cards (skip spacers)
    const offScreenSlots = layoutPattern.filter((slot, idx) => {
      if (slot.isSpacer) return false;
      const row = Math.floor(idx / cardsPerRow);
      const estimatedY = row * rowHeight;
      return estimatedY < topBound || estimatedY > bottomBound;
    });

    if (offScreenSlots.length === 0) return;

    // Rotate content in off-screen cards only
    setCardContent(prev => {
      const newContent = { ...prev };
      const unusedNotes = notes.filter(note =>
        !Object.values(prev).some(card => card?.id === note.id)
      );

      offScreenSlots.forEach(slot => {
        if (unusedNotes.length > 0) {
          const randomNote = unusedNotes[Math.floor(Math.random() * unusedNotes.length)];
          newContent[slot.id] = randomNote;
          unusedNotes.splice(unusedNotes.indexOf(randomNote), 1);
        }
      });

      return newContent;
    });

    lastRotationRef.current = now;
  }, [scrollPosition, notes, displayDuration, layoutPattern, cardsPerRow, getVisibleRange]);

  // Auto-scroll speed mapping
  const scrollSpeedValue = useMemo(() => {
    const speeds = {
      slow: 0.25,
      medium: 0.5,
      fast: 0.8
    };
    return speeds[scrollSpeed] || 0.5;
  }, [scrollSpeed]);

  // Focus frequency mapping
  const focusFrequencyValue = useMemo(() => {
    const frequencies = {
      never: 0,
      rare: 3,
      normal: 1,
      frequent: 0.5
    };
    return frequencies[focusFrequency] || 1;
  }, [focusFrequency]);

  // Smooth scroll animation using RAF
  useEffect(() => {
    if (notes.length === 0) {
      return;
    }

    const animate = () => {
      const now = Date.now();
      const delta = now - lastScrollTimeRef.current;
      lastScrollTimeRef.current = now;

      const scrollDelta = scrollSpeedValue * delta / 16.67;
      setScrollPosition(prev => prev + scrollDelta);

      animationFrameRef.current = requestAnimationFrame(animate);
    };

    animationFrameRef.current = requestAnimationFrame(animate);

    return () => {
      if (animationFrameRef.current) {
        cancelAnimationFrame(animationFrameRef.current);
      }
    };
  }, [scrollSpeedValue, notes.length]);

  // Random focus effect - show focused card in overlay
  useEffect(() => {
    if (focusFrequencyValue === 0 || notes.length === 0) {
      return;
    }

    const focusCard = () => {
      // Get non-spacer slots only
      const cardSlots = layoutPattern.filter(slot => !slot.isSpacer);
      if (cardSlots.length === 0) return;

      const randomSlot = cardSlots[Math.floor(Math.random() * cardSlots.length)];
      const rotation = Math.random() * 6 - 3; // Calculate rotation once

      setFocusedRotation(rotation);
      setIsExiting(false);
      setFocusedIndex(randomSlot.id);

      setTimeout(() => {
        setIsExiting(true);
        setTimeout(() => {
          setFocusedIndex(null);
          setIsExiting(false);
        }, 200); // Wait for exit animation to complete
      }, zoomDuration);
    };

    // Initial focus after half the interval
    const initialDelay = focusFrequencyValue * 30000;
    const initialTimeout = setTimeout(focusCard, initialDelay);

    // Regular interval
    const intervalTime = focusFrequencyValue * 60000;
    const interval = setInterval(focusCard, intervalTime);

    return () => {
      clearTimeout(initialTimeout);
      clearInterval(interval);
    };
  }, [focusFrequencyValue, zoomDuration, notes.length, layoutPattern]);

  // Get card classes based on size (height adjusted for note aspect ratio)
  const getCardClasses = (size) => {
    const baseClasses = 'bg-white rounded-2xl shadow-2xl overflow-hidden transition-all duration-300';

    switch (size) {
      case '1x1':
        return `${baseClasses} col-span-1 row-span-3`; // 3:4 ratio, 1 column, 3 rows
      case '2x3':
        return `${baseClasses} col-span-2 row-span-5`; // Fixed height, 2 columns, 5 rows
      default:
        return `${baseClasses} col-span-1 row-span-3`;
    }
  };

  // Get header padding based on card size and branding settings
  const getHeaderPadding = (size) => {
    const paddingMultiplier = {
      compact: 0.5,
      normal: 1,
      spacious: 1.5
    }[branding.headerPadding] || 1;

    switch (size) {
      case '1x1':
        return { paddingLeft: '0.75rem', paddingRight: '0.75rem', paddingTop: `${0.5 * paddingMultiplier}rem`, paddingBottom: `${0.5 * paddingMultiplier}rem` };
      case '1x2':
        return { paddingLeft: '1rem', paddingRight: '1rem', paddingTop: `${0.75 * paddingMultiplier}rem`, paddingBottom: `${0.75 * paddingMultiplier}rem` };
      case '2x3':
      case '2x4':
        return { paddingLeft: '1.5rem', paddingRight: '1.5rem', paddingTop: `${1 * paddingMultiplier}rem`, paddingBottom: `${1 * paddingMultiplier}rem` };
      default:
        return { paddingLeft: '1rem', paddingRight: '1rem', paddingTop: `${0.75 * paddingMultiplier}rem`, paddingBottom: `${0.75 * paddingMultiplier}rem` };
    }
  };

  // Get focused header padding (larger scale for focus view)
  const getFocusedHeaderPadding = () => {
    const paddingMultiplier = {
      compact: 0.75,
      normal: 1.25,
      spacious: 2
    }[branding.headerPadding] || 1.25;

    return {
      paddingLeft: '2rem',
      paddingRight: '2rem',
      paddingTop: `${1.25 * paddingMultiplier}rem`,
      paddingBottom: `${1.25 * paddingMultiplier}rem`
    };
  };

  // Get header font size based on card size and branding settings
  const getHeaderFontSize = (size, element) => {
    const sizeMultiplier = {
      small: 0.85,
      native: 1,
      big: 1.2
    }[branding.headerFontSize] || 1;

    // Base sizes for different card sizes
    let baseTitleSize, baseSubtitleSize;
    switch (size) {
      case '1x1':
        baseTitleSize = element === 'title' ? 0.75 : 0.75; // text-xs
        baseSubtitleSize = 0.75; // text-xs
        break;
      case '1x2':
        baseTitleSize = element === 'title' ? 0.875 : 0.875; // text-sm
        baseSubtitleSize = 0.875; // text-sm
        break;
      case '2x3':
      case '2x4':
        baseTitleSize = element === 'title' ? 1.125 : 1.125; // text-lg
        baseSubtitleSize = 1; // text-base
        break;
      default:
        baseTitleSize = element === 'title' ? 0.875 : 0.875; // text-sm
        baseSubtitleSize = 0.875; // text-sm
    }

    const finalSize = element === 'title' ? baseTitleSize * sizeMultiplier : baseSubtitleSize * sizeMultiplier;
    return `${finalSize}rem`;
  };

  // Get focused header font size (larger scale for focus view)
  const getFocusedHeaderFontSize = (element) => {
    const sizeMultiplier = {
      small: 0.85,
      native: 1,
      big: 1.2
    }[branding.headerFontSize] || 1;

    const baseSize = element === 'title' ? 1.875 : 1.25; // text-3xl : text-xl
    return `${baseSize * sizeMultiplier}rem`;
  };

  // Get background style based on branding settings
  const getBackgroundStyle = () => {
    const angle = branding.gradientAngle || 135;
    switch (branding.backgroundType) {
      case 'solid':
        return { backgroundImage: 'none', backgroundColor: branding.backgroundColor };
      case 'gradient':
        return {
          backgroundImage: `linear-gradient(${angle}deg, ${branding.gradientStart}, ${branding.gradientEnd})`,
          backgroundColor: branding.gradientStart // Fallback color to prevent transparency
        };
      case 'image':
        return branding.backgroundImage
          ? { backgroundImage: `url(${branding.backgroundImage})`, backgroundSize: 'cover', backgroundPosition: 'center', backgroundColor: '#000' }
          : {
              backgroundImage: `linear-gradient(${angle}deg, ${branding.gradientStart}, ${branding.gradientEnd})`,
              backgroundColor: branding.gradientStart
            };
      default:
        return {
          backgroundImage: `linear-gradient(${angle}deg, ${branding.gradientStart}, ${branding.gradientEnd})`,
          backgroundColor: branding.gradientStart
        };
    }
  };

  // Get header gradient style
  const getHeaderStyle = () => {
    const angle = branding.headerGradientAngle || 90;
    return {
      backgroundImage: `linear-gradient(${angle}deg, ${branding.headerColorStart}, ${branding.headerColorEnd})`,
      backgroundColor: 'transparent',
      fontFamily: branding.headerFont
    };
  };

  // Get image fit based on card size
  const getImageFit = (size) => {
    // Native aspect ratio sizes: show entire note with no crop
    if (size === '1x2' || size === '2x4') {
      return 'object-contain';
    }
    // Fixed sizes: crop to fill the card dimensions
    return 'object-cover';
  };

  if (notes.length === 0) {
    return (
      <div className="min-h-screen flex items-center justify-center" style={getBackgroundStyle()}>
        <p className="text-2xl text-gray-400">No thank you notes to display</p>
      </div>
    );
  }

  return (
    <>
    <div
      ref={containerRef}
      className="min-h-screen overflow-hidden relative"
      style={{ perspective: '1000px', ...getBackgroundStyle() }}
    >
      <div
        ref={gridRef}
        className={`grid gap-4 p-8 auto-rows-[100px] transition-transform duration-100 ease-linear`}
        style={{
          transform: `translateY(-${scrollPosition}px) translateZ(0)`,
          willChange: 'transform',
          gridTemplateColumns: `repeat(${cardsPerRow}, 1fr)`
        }}
      >
        {layoutPattern.map((slot, index) => {
          // Render spacer as empty div
          if (slot.isSpacer) {
            return (
              <div
                key={slot.id}
                className="col-span-1 row-span-1"
              />
            );
          }

          const note = cardContent[slot.id];
          if (!note) return null;

          const size = slot.size;

          return (
            <div
              key={slot.id}
              className={`${getCardClasses(size)} flex flex-col`}
            >
              {/* Card Header */}
              <div className="flex-shrink-0" style={{ ...getHeaderStyle(), ...getHeaderPadding(size) }}>
                <h3 className="font-bold text-white" style={{ fontSize: getHeaderFontSize(size, 'title') }}>
                  To: {note.iPad_input?.recipient || 'Unknown'}
                </h3>
                <p className="text-white/80" style={{ fontSize: getHeaderFontSize(size, 'subtitle') }}>
                  From: {note.iPad_input?.sender || 'Unknown'}
                </p>
              </div>

              {/* Card Image */}
              <div className="relative w-full flex-1 overflow-hidden bg-gray-50">
                <img
                  src={`data:image/png;base64,${note.iPad_input?.drawingImage}`}
                  alt="Thank you note"
                  className="w-full h-full object-cover"
                  loading="lazy"
                />
              </div>
            </div>
          );
        })}
      </div>
    </div>

      {/* Focus Overlay - Rendered outside overflow-hidden container */}
      {focusedIndex && cardContent[focusedIndex] && (
        <div
          style={{
            position: 'fixed',
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            zIndex: 99999,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            padding: '2rem',
            backgroundColor: 'rgba(0, 0, 0, 0.2)',
            backdropFilter: 'blur(7px)',
            WebkitBackdropFilter: 'blur(7px)',
            animation: isExiting ? 'fadeOutBackground 0.2s ease-out' : 'fadeInBackground 0.6s ease-out'
          }}
        >
          <div
            style={{
              position: 'relative',
              width: '100%',
              maxWidth: '31.5rem',
              transform: `rotate(${focusedRotation}deg)`,
              animation: isExiting ? 'slideOutCard 0.2s ease-out' : 'slideInCard 0.7s cubic-bezier(0.34, 1.56, 0.64, 1)'
            }}
          >
            <div
              style={{
                backgroundColor: 'white',
                borderRadius: '1rem',
                boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.25)',
                overflow: 'hidden',
                display: 'flex',
                flexDirection: 'column',
                maxHeight: '85vh'
              }}
            >
              {/* Card Header */}
              <div
                style={{
                  ...getHeaderStyle(),
                  ...getFocusedHeaderPadding(),
                  flexShrink: 0
                }}
              >
                <h3 style={{ fontWeight: 'bold', color: 'white', fontSize: getFocusedHeaderFontSize('title'), margin: 0 }}>
                  To: {cardContent[focusedIndex].iPad_input?.recipient || 'Unknown'}
                </h3>
                <p style={{ color: 'rgba(255, 255, 255, 0.9)', fontSize: getFocusedHeaderFontSize('subtitle'), marginTop: '0.5rem', marginBottom: 0 }}>
                  From: {cardContent[focusedIndex].iPad_input?.sender || 'Unknown'}
                </p>
              </div>

              {/* Card Image */}
              <div
                style={{
                  position: 'relative',
                  flex: 1,
                  width: '100%',
                  backgroundColor: 'rgb(249, 250, 251)',
                  minHeight: '400px',
                  maxHeight: '70vh',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  overflow: 'hidden'
                }}
              >
                <img
                  src={`data:image/png;base64,${cardContent[focusedIndex].iPad_input?.drawingImage}`}
                  alt="Thank you note"
                  style={{
                    maxWidth: '100%',
                    maxHeight: '100%',
                    objectFit: 'contain'
                  }}
                />
              </div>
            </div>
          </div>
        </div>
      )}

      <style dangerouslySetInnerHTML={{__html: `
        @keyframes fadeInBackground {
          0% {
            opacity: 0;
            backdrop-filter: blur(0px);
            -webkit-backdrop-filter: blur(0px);
          }
          100% {
            opacity: 1;
            backdrop-filter: blur(7px);
            -webkit-backdrop-filter: blur(7px);
          }
        }

        @keyframes fadeOutBackground {
          0% {
            opacity: 1;
            backdrop-filter: blur(7px);
            -webkit-backdrop-filter: blur(7px);
          }
          100% {
            opacity: 0;
            backdrop-filter: blur(0px);
            -webkit-backdrop-filter: blur(0px);
          }
        }

        @keyframes slideInCard {
          0% {
            transform: scale(0.7) translateY(30px);
            opacity: 0;
          }
          60% {
            transform: scale(1.02);
          }
          100% {
            transform: scale(1) translateY(0);
            opacity: 1;
          }
        }

        @keyframes slideOutCard {
          0% {
            transform: scale(1) translateY(0);
            opacity: 1;
          }
          100% {
            transform: scale(0.8) translateY(20px);
            opacity: 0;
          }
        }
      `}} />
    </>
  );
};

export default PortraitMode;
