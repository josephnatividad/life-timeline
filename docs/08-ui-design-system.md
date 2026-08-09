# UI Design System --- Quiet Intelligence

## Direction

**Quiet Intelligence**

Modern and futuristic through hierarchy, motion, intelligence and
temporal relationships---not neon AI clichés.

Principles:

-   Personal
-   Quiet
-   Intelligent
-   Temporal
-   Private
-   Timeless
-   Accessible

## Color tokens

### Light

``` text
background          #F8F8FA
surface             #FFFFFF
surfaceSecondary    #F2F2F6
textPrimary         #18181B
textSecondary       #71717A
textTertiary        #A1A1AA
border              #E4E4E7
divider             #ECECEF
primary             #5451D6
primarySoft         #EEEEFF
success             #2E8B68
warning             #C88725
danger              #D14D4D
```

### Dark

``` text
background          #0D0D10
surface             #16161B
surfaceSecondary    #1E1E24
textPrimary         #F5F5F7
textSecondary       #A1A1AA
textTertiary        #71717A
border              #29292F
primary             #8B87FF
primarySoft         #24223D
```

Gradients are reserved for intelligence/memory emphasis and Stories. Do
not decorate ordinary UI with gradients.

## Typography

Prefer platform-appropriate/system typography or a carefully licensed
modern sans. Keep typography centralized.

Suggested scale:

``` text
Display       40/48 SemiBold
Hero          32/40 SemiBold
Title 1       28/34 SemiBold
Title 2       22/28 SemiBold
Title 3       18/24 SemiBold
Body Large    17/26 Regular
Body          15/22 Regular
Body Small    13/18 Regular
Label         13/18 Medium
Caption       11/16 Medium
```

## Spacing

Use an 8-point-oriented token system:

``` text
4, 8, 12, 16, 20, 24, 32, 40, 48, 64
```

No arbitrary padding values in feature widgets without justification.

## Radius

``` text
small control   8
button         12
card           16
large card     20
bottom sheet   28
pill           full
```

## Navigation

Target five primary destinations:

``` text
Timeline | Explore | Capture | Stories | You
```

Capture is the primary action, but should not visually overpower the
navigation.

## Signature components

-   TimelineNode
-   TimelineHero
-   MemoryCard
-   IntelligenceCard
-   PrivacyNotice
-   MemoryInboxCard
-   StoryCard
-   BackupHealthCard
-   StorageHealthCard
-   EmptyState
-   TimeScrubber

## Timeline

Avoid a generic feed of cards.

The timeline line, nodes, dates, event hierarchy and occasional visual
hero memories should form the product's visual signature.

## Intelligence

Use a restrained `✦`/custom intelligence symbol.

AI should appear contextually:

-   AI Capture
-   Insight
-   Suggested Memory
-   Ask My Life

Avoid robot mascots and chatbot-first UI.

## Accessibility

Design system must support:

-   Dynamic text
-   Screen readers
-   High contrast
-   Large touch targets
-   Reduced motion
-   Keyboard/focus behavior where applicable
-   Semantic labels
