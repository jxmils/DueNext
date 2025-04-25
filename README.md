# DueNext

## Table of Contents
- [Overview](#overview)
  - [Description](#description)
  - [App Evaluation](#app-evaluation)
- [Product Spec](#product-spec)
  - [1. User Stories (Required and Optional)](#1-user-stories-required-and-optional)
  - [2. Screen Archetypes](#2-screen-archetypes)
  - [3. Navigation](#3-navigation)
- [Wireframes](#wireframes)
- [Schema](#schema)

---

## Overview

### Description

**DueNext** is a modern iOS productivity app built for students to manage their academic assignments in a simple, elegant, and efficient way. The app features a widget that shows the next due assignment, support for custom subjects and logos, intuitive swipe gestures to mark tasks complete or delete them, and a responsive calendar interface.

### App Evaluation

- **Category:** Productivity / Education  
- **Mobile:** iOS 17+ (SwiftUI native app)  
- **Story:** Users add assignments with due dates and subjects, track upcoming tasks, and manage their academic workflow effortlessly.  
- **Market:** Targeted at middle school, high school, and college students who want a clean, non-overwhelming assignment manager.  
- **Habit:** Designed for daily use, with quick input and glanceable widgets to keep students on top of deadlines.  
- **Scope:** MVP focuses on adding/viewing assignments, viewing by calendar, and widget integration. Future features may include syncing with school portals, reminders, and AI suggestions.

---

## Product Spec

### 1. User Stories (Required and Optional)

#### Required Must-have Stories
- [x] Users can add new assignments with title, due date, time, and subject
- [x] Users can mark assignments as complete
- [x] Users can delete assignments with a swipe gesture
- [x] Assignments show up in a calendar view
- [x] A home screen widget displays the next due assignment
- [x] App prevents due dates in the past

#### Optional Nice-to-have Stories
- [ ] Custom colors and icons for subjects
- [ ] Integration with StudentVUE for syncing assignments
- [ ] Reminder notifications
- [ ] View statistics (e.g. streaks, task completion history)
- [ ] Natural language input (e.g. "Math test due tomorrow")

---

### 2. Screen Archetypes

#### ➤ Add Assignment Screen
- Users input assignment details (title, date, time, subject)
- Supports new subject creation and subject selection

#### ➤ Assignment List Screen
- Displays all active assignments
- Allows marking as complete or deleting via swipe

#### ➤ Calendar Screen
- Visual calendar with assignment overlays
- Clicking a date filters visible assignments

#### ➤ Settings Screen (optional)
- Customize theme, subject colors/icons, and widget preferences

---

### 3. Navigation

#### Tab Navigation (Tab to Screen)
- 📋 Assignment List → [Assignment List Screen]
- 📅 Calendar → [Calendar Screen]
- ⚙️ Settings → [Settings Screen]

#### Flow Navigation (Screen to Screen)
- Assignment List → Add Assignment
- Calendar → Add Assignment
- Settings → Edit Subject Preferences
- Widget Tap → App opens directly to Assignment List or specific task

---

## Schema

*This is where you'll define your data model. Example:*

**Assignment Object**
- `id` (UUID)
- `title`: String
- `dueDate`: Date
- `subject`: String
- `isCompleted`: Bool

**Subject Object**
- `name`: String
- `icon`: String (e.g. emoji or SF Symbol name)
- `color`: Hex or Color object

---

<div>
    <a href="https://www.loom.com/share/4c61cf16c52e4652af749369f2c9ef44">
      <p>Demo</p>
    </a>
    <a href="https://www.loom.com/share/4c61cf16c52e4652af749369f2c9ef44">
      <img style="max-width:300px;" src="https://cdn.loom.com/sessions/thumbnails/4c61cf16c52e4652af749369f2c9ef44-23944786d8e3add0-full-play.gif">
    </a>
  </div>
