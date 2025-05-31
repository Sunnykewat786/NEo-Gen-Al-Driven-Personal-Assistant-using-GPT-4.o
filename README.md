# NEo-Gen-Al-Driven-Personal-Assistant-using-GPT-4.o
Developed a mobile app combining AI-powered modules: chatbot (ChatGPT), image generation (DALL·E), multi-language translation, note-taking, summarization • Built using Flutter and Dart with modular architecture for seamless updates; offline capabilities supported via Hive and integrations with REST APIs •

# Neo: Gen AI Driven Personal Assistant Using GPT-4.0

Neo is a Flutter-based mobile application designed as an intelligent, multimodal personal assistant that goes beyond traditional voice-command systems. It combines conversational AI, image generation, real-time translation, productivity tools, and offline capabilities — all in one unified platform.

## 🚀 Features

### 🤖 AI Chatbot
- Built using custom LLM and integrates with Wikipedia & YouTube
- Context-aware, conversational, supports text and voice input
- Allows output customization (e.g., bullet points)

### 🎨 AI Image Generator & Fetcher
- Generates images from text prompts using Latent Diffusion Models
- Retrieves real-world images using semantic keyword search

### 🌐 Language Translator
- Real-time, two-way multilingual translation
- Supports text input and speech-to-text (STT) + text-to-speech (TTS)
- Offline storage of previous translations

### 📝 Smart Note Taking
- Create, pin, edit, and organize notes with Hive local storage
- Integrates directly with chatbot for note saving

### ✅ To-Do List & Task Manager
- Calendar-based task scheduling with reminders and subtasks
- Local notifications and offline access via Hive

### 📄 Smart Summarizer
- Summarizes long texts or PDFs into concise key points
- Outputs can be saved directly to notes

# ⚙️ Architecture

Neo is designed using a modular, layered architecture:

- **Input Layer**: Handles text and speech input using advanced STT pipeline
- **Preprocessing Layer**: Performs intent detection, entity extraction, and context tracking using BERT and BiLSTM-CRF
- **AI Core Layer**: Orchestrates task routing, personalization, and execution using DAG and FSM
- **Integration Layer**: Connects to services for image generation, text generation, translation, etc.
- **Post-processing Layer**: Fuses multimodal responses, scores output quality
- **Output Layer**: Delivers structured, user-friendly responses
- **Feedback Loop**: Learns from usage patterns and improves via meta-learning and reinforcement updates

# 🧠 Tech Stack

- **Frontend**: Flutter
- **Storage**: Hive (for local, offline access)
- **AI Models**:
  - GPT-style custom LLM for chatbot
  - Latent Diffusion Model for image generation
  - Google NMT + STT/TTS for translation
  - BERT, BiLSTM-CRF, SRL, and others for NLP processing
- **APIs**: Wikipedia, YouTube, Image REST APIs
- **Backend Coordination**: FSM, DAG scheduler, Dueling DQN agent for model selection

## 📊 Results

- High F1-scores in intent (94.1%) and entity recognition (92.6%)
- Smooth multimodal interactions across modules
- Effective offline support for notes, tasks, and translations
- Positive user feedback on usability and interface

## 🔐 Privacy

Neo stores all sensitive data locally using Hive with encryption — ensuring user data remains private and accessible without internet connectivity.

## 📌 Future Enhancements

- Deeper personalization and preference learning
- Enhanced context memory and user profiles
- Broader language and task support

## 📄 Paper Reference

> Pushkar Jawale, Rahul Gorana, Sunny Kevat, Dr. Nita Patil,  
> “Neo: Gen AI Driven Personal Assistance Using GPT 4.0”  
> *International Research Journal of Engineering and Technology (IRJET), Volume 12, Issue 4, April 2025*  
> [Read Full Paper](https://www.irjet.net/archives/V12/i4/IRJET-V12I4177.pdf)

---
