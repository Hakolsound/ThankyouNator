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

  // Fixed layout grid with 100 card slots
  const TOTAL_CARDS = 100;

  // Generate sporadic layout with spacers for visual interest
  const layoutPattern = useMemo(() => {
    const pattern = [];

    // Use seeded random for consistent layout
    let seed = 12345;
    const seededRandom = () => {
      seed = (seed * 9301 + 49297) % 233280;
      return seed / 233280;
    };

    // Pre-determine big card positions with enforced spacing (20% = 20 out of 100)
    // Distribute them evenly to prevent clustering
    const totalBigCards = Math.floor(TOTAL_CARDS * 0.20); // 20 cards
    const bigCardIndices = [];
    const minGap = Math.floor(TOTAL_CARDS / totalBigCards) - 1; // Minimum gap between big cards

    for (let i = 0; i < totalBigCards; i++) {
      // Calculate base position with even spacing
      const basePos = Math.floor((TOTAL_CARDS / totalBigCards) * i);
      // Add small random offset for natural feel
      const offset = Math.floor(seededRandom() * minGap);
      const position = Math.min(basePos + offset, TOTAL_CARDS - 1);
      bigCardIndices.push(position);
    }

    const bigCardSet = new Set(bigCardIndices);

    let currentColumn = 0;
    let slotIndex = 0;
    let bigCardCount = 0; // Track how many big cards we've placed

    // Social feed: Masonry layout with alternating big cards and random spacers
    while (slotIndex < TOTAL_CARDS) {
      let size, colSpan;

      // Check if this card should be big
      const isBigCard = bigCardSet.has(slotIndex);

      // Only add random spacers if we're NOT about to place a big card
      // This prevents spacers from messing up big card positioning
      if (!isBigCard && seededRandom() < 0.10 && currentColumn < cardsPerRow - 1) {
        pattern.push({ id: `spacer-random-${slotIndex}-${currentColumn}`, size: 'spacer', isSpacer: true });
        currentColumn++;
      }

      if (isBigCard) {
        size = '2x3';
        colSpan = 2;

        // FORCE strict alternation: even big cards go left (0), odd go right (1)
        const targetColumn = bigCardCount % 2; // 0, 1, 0, 1, 0, 1...
        bigCardCount++;

        // Move to target column
        if (currentColumn < targetColumn) {
          // Add small cards to reach target column instead of empty spacers
          while (currentColumn < targetColumn) {
            pattern.push({ id: `filler-${slotIndex}-${currentColumn}`, size: '1x1', colSpan: 1, gridColumnStart: currentColumn + 1 });
            currentColumn++;
          }
        } else if (currentColumn > targetColumn) {
          // Fill remaining columns with small cards, then wrap to next row
          while (currentColumn < cardsPerRow) {
            pattern.push({ id: `filler-end-${slotIndex}-${currentColumn}`, size: '1x1', colSpan: 1, gridColumnStart: currentColumn + 1 });
            currentColumn++;
          }
          currentColumn = 0;
          // Add small cards to reach target column
          while (currentColumn < targetColumn) {
            pattern.push({ id: `filler-start-${slotIndex}-${currentColumn}`, size: '1x1', colSpan: 1, gridColumnStart: currentColumn + 1 });
            currentColumn++;
          }
        }
      } else {
        size = '1x1';
        colSpan = 1;
      }

      // If card doesn't fit in current row, fill remaining space with small cards and wrap
      if (currentColumn + colSpan > cardsPerRow) {
        while (currentColumn < cardsPerRow) {
          pattern.push({ id: `filler-wrap-${slotIndex}-${currentColumn}`, size: '1x1', colSpan: 1, gridColumnStart: currentColumn + 1 });
          currentColumn++;
        }
        currentColumn = 0;
      }

      // Add the card with its starting column position
      const gridColumnStart = currentColumn + 1; // CSS grid is 1-indexed
      pattern.push({ id: `slot-${slotIndex}`, size, colSpan, gridColumnStart });
      currentColumn += colSpan;

      // Reset column counter when row is complete
      if (currentColumn >= cardsPerRow) {
        currentColumn = 0;
      }

      slotIndex++;
    }

    return pattern;
  }, [cardsPerRow]); // Regenerate when cardsPerRow changes

  // Assign notes to card slots - simple, no viewport tracking
  const [cardContent, setCardContent] = useState({});
  const contentHeightRef = useRef(0);

  // Simple content assignment - no viewport tracking
  // New notes will appear naturally on next loop cycle
  useEffect(() => {
    if (notes.length === 0) {
      setCardContent({});
      return;
    }

    // Only initialize if we don't have content yet
    setCardContent(prev => {
      if (Object.keys(prev).length > 0) {
        return prev; // Keep existing content
      }

      // Initial load - shuffle and assign
      const cardSlots = layoutPattern.filter(slot => !slot.isSpacer);
      const content = {};
      const shuffledNotes = [...notes].sort(() => Math.random() - 0.5);

      cardSlots.forEach((slot, idx) => {
        content[slot.id] = shuffledNotes[idx % shuffledNotes.length];
      });

      return content;
    });
  }, [layoutPattern, notes.length]); // Only for initial load

  // Measure content height once when layout changes
  useEffect(() => {
    if (gridRef.current) {
      const height = gridRef.current.getBoundingClientRect().height;
      contentHeightRef.current = height;
    }
  }, [layoutPattern, notes.length]);


  // Auto-scroll speed mapping
  const scrollSpeedValue = useMemo(() => {
    const speeds = {
      slow: 0.3,
      medium: 0.6,
      fast: 1
    };
    return speeds[scrollSpeed] || 0.6;
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

  // Store refs to avoid re-creating animation loop
  const layoutPatternRef = useRef(layoutPattern);
  const notesRef = useRef(notes);
  const scrollSpeedRef = useRef(scrollSpeedValue);

  useEffect(() => {
    layoutPatternRef.current = layoutPattern;
  }, [layoutPattern]);

  useEffect(() => {
    notesRef.current = notes;
  }, [notes]);

  useEffect(() => {
    scrollSpeedRef.current = scrollSpeedValue;
  }, [scrollSpeedValue]);

  // Auto-scroll with infinite loop - optimized with refs
  useEffect(() => {
    if (notesRef.current.length === 0) {
      return;
    }

    // Reset timestamp on effect start
    lastScrollTimeRef.current = null;

    const animate = (timestamp) => {
      if (!lastScrollTimeRef.current) {
        lastScrollTimeRef.current = timestamp;
        animationFrameRef.current = requestAnimationFrame(animate);
        return;
      }

      const delta = timestamp - lastScrollTimeRef.current;
      lastScrollTimeRef.current = timestamp;

      // Smooth delta capping to prevent jumps
      const cappedDelta = Math.min(delta, 32); // Cap at 2 frames worth
      const scrollDelta = scrollSpeedRef.current * cappedDelta / 16.67;

      setScrollPosition(prev => {
        const newPosition = prev + scrollDelta;
        const contentHeight = contentHeightRef.current || 2500;
        const viewportHeight = window.innerHeight;

        // Loop when we've scrolled past the entire content (at the end, not before)
        if (newPosition > contentHeight + viewportHeight * 2) {
          // Shuffle all content for next cycle
          setCardContent(() => {
            const cardSlots = layoutPatternRef.current.filter(slot => !slot.isSpacer);
            const content = {};
            const shuffledNotes = [...notesRef.current].sort(() => Math.random() - 0.5);

            cardSlots.forEach((slot, idx) => {
              content[slot.id] = shuffledNotes[idx % shuffledNotes.length];
            });

            return content;
          });

          return 0; // Reset to beginning
        }

        return newPosition;
      });

      animationFrameRef.current = requestAnimationFrame(animate);
    };

    animationFrameRef.current = requestAnimationFrame(animate);

    return () => {
      if (animationFrameRef.current) {
        cancelAnimationFrame(animationFrameRef.current);
      }
    };
  }, []); // Empty dependency array - use refs instead

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
        className="grid gap-4 p-8 auto-rows-[100px]"
        style={{
          gridTemplateColumns: `repeat(${cardsPerRow}, 1fr)`,
          transform: `translate3d(0, -${scrollPosition}px, 0)`,
          willChange: 'transform',
          backfaceVisibility: 'hidden',
          WebkitBackfaceVisibility: 'hidden',
          WebkitFontSmoothing: 'antialiased',
          transformStyle: 'preserve-3d'
        }}
      >
        {layoutPattern.map((slot) => {
          if (slot.isSpacer) {
            return <div key={slot.id} className="col-span-1 row-span-1" />;
          }

          const note = cardContent[slot.id];
          if (!note) return null;

          const size = slot.size;

          return (
            <div
              key={slot.id}
              data-slot-id={slot.id}
              className={`${getCardClasses(size)} flex flex-col`}
              style={{
                gridColumnStart: slot.gridColumnStart,
                gridColumnEnd: slot.gridColumnStart + slot.colSpan,
                contain: 'layout style paint',
                contentVisibility: 'auto',
                transform: 'translateZ(0)',
                backfaceVisibility: 'hidden',
                WebkitBackfaceVisibility: 'hidden',
                WebkitFontSmoothing: 'antialiased'
              }}
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
                  className={`w-full h-full ${getImageFit(size)}`}
                  loading="lazy"
                  decoding="async"
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
            backgroundColor: 'rgba(0, 0, 0, 0.3)',
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
