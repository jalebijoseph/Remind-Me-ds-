# Remind Me(ds) 💊

> **Your meds, your schedule, and your health cared for.**

Remind Me(ds) is a pastel-styled, cross-platform medication management app built with **Flutter** and **Supabase**. It helps users:

- Log medications, purposes, illnesses, dosages, and pill counts  
- Track remaining pills and get **refill alerts**  
- Receive **daily notifications** to take doses  
- View **cheapest pharmacy prices** for a medication by ZIP code  
- Enjoy an accessible, soft, healthcare-friendly UI with **light & dark pastel themes**

---

## ✨ Features

- 🔐 Email/password auth via Supabase
- 📋 Add / edit / delete medications
- ⏰ Local notifications for daily reminders
- 📉 Pill count auto-decrements when a dose is taken
- ⚠️ Refill alerts when remaining pills fall below a threshold
- 🏥 Pharmacy price lookup screen (drug + ZIP)
- 🌸 Light & dark pastel themes
- 📱 Works on Android, iOS, and Web (with some notification caveats)

---

## 🛠 Tech Stack

- Flutter 3
- Supabase (Auth + Postgres + RLS)
- flutter_local_notifications
- timezone
- http

---

## 🚀 Getting Started

1. **Clone this repo**

```bash
git clone https://github.com/YOUR_USERNAME/remind-me-ds.git
cd remind-me-ds
