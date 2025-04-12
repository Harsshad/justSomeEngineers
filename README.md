<h1 align="center">🚀 CodeFusion</h1>
<h3 align="center">🌐 Your Complete Developer Collaboration Platform</h3>

<p align="center">
  <a href="https://codefusion-f6d69.web.app/" target="_blank">
    <img src="https://img.shields.io/badge/Live-Demo-success?style=flat-square&logo=vercel&color=brightgreen" />
  </a>
  <img src="https://img.shields.io/github/license/harsshad/CodeFusion?style=flat-square" />
  <img src="https://img.shields.io/github/stars/harsshad/CodeFusion?style=social" />
  <img src="https://img.shields.io/github/forks/harsshad/CodeFusion?style=social" />
</p>

<p align="center">
  <img src="https://github.com/harsshad/CodeFusion/assets/demo.gif" alt="CodeFusion UI Preview" width="800" />
</p>

---

## 🧠 What is CodeFusion?

> CodeFusion is an all-in-one platform for developers to learn, grow, and collaborate. Whether you're a student, a mentor, or a professional — we've got something for you.

Built with **Flutter + Firebase**, it's cross-platform, modern, and packed with powerful modules — from AI chatbots to mentorship, code Q&A, dev chats, job boards, and resume generation.

---

## 🌟 Features & Modules

### 🏠 Home
- Showcases **7 latest mentors** (real-time, scrollable).
- Displays trending **Dev.to articles** via API integration.

### 👨‍💻 Profile Page
- Users & mentors can view full profiles.
- Users get an **Edit Profile** option.

### 🤖 CodeMate (AI ChatBot)
- Integrated with **Gemini API**.
- Ask code, career, or tech questions.

### ❓ CodeQuery (Q&A)
- Ask and answer questions.
- Upload images, links, get **upvotes/downvotes**.
- Most voted answer appears at the top.

### 🧑‍🏫 DevGuru (Mentorship)
- Mentors see:
  - ✅ Mentee Requests
  - ✅ My Mentees
  - ✅ Profile Editor
- Users see:
  - 🔍 Mentor List with filters (Web Dev, App Dev, etc.)
  - 📬 Applied Mentors
- Requests flow with **approval system**.

### 📹 FusionMeet
- Seamless **video calling** via `Jitsi Meet`.
- **Only available on mobile platforms**.

### 📚 Resource Library
- 🔍 Search any tech/language.
- Tabs:
  - 📄 **Articles** from Dev.to & Medium.
  - 🎥 **Videos** from YouTube API.
  - 🗺️ **Roadmaps** with Save & Manage features.

### 💬 DevChat (Messaging)
- Real-time 1-on-1 chat.
- Tab separation: 🧑 Users | 🧑‍🏫 Mentors
- 🔒 Block & report system included.
- 🔴 Shows unread message count.

### 📄 Resume Generator
- Enter details, auto-generate a **professional resume** PDF.

### 💼 Job Board
- Powered by **LinkedIn API**.
- Role-based, company-based job search in real-time.

### ⚙️ Settings
- 🌙 Dark Mode toggle.
- 👥 View & Unblock users.

### 🔐 Auth System
- Firebase Auth with:
  - Email/Password Login
  - Role-based dashboard

---

## 📲 Hosted Web App

### 🔗 [🌍 View Live Demo](https://codefusion-f6d69.web.app/)

> 💡 Optimized for both Web & Mobile. FusionMeet is mobile-only.

---

## 🔧 Tech Stack

| Layer       | Tech Used                         |
|-------------|-----------------------------------|
| 📱 Frontend | Flutter                           |
| 🔥 Backend  | Firebase (Auth, Firestore, Storage) |
| 🤖 AI       | Gemini API (for chatbot)          |
| 📞 Calls     | Jitsi Meet SDK                    |
| 📡 APIs     | Dev.to, Medium, YouTube, LinkedIn |
| 📦 State    | Provider                          |

---

## 🧪 Algorithms Used

- 🔎 **Search Filter** for mentor/user search
- 📥 **StreamBuilder + Firestore Listeners** for real-time updates
- 🗳️ **Upvote/Downvote Sorting** for Q&A
- 📤 **Unread Message Tracker** using message metadata
- 🧠 **Gemini NLP** for chatbot integration
- 🧮 **Role-Based Access** (Mentor/User-based UI switching)

---

## 🚀 How To Use

```bash
# 1. Clone the repository
git clone https://github.com/harsshad/CodeFusion.git

# 2. Open with Flutter-supported IDE (e.g., VSCode)

# 3. Run the app
flutter run -d chrome # for web
flutter run -d <device_id> # for mobile
