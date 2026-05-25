#!/bin/bash
# ══════════════════════════════════════════════════════════════════════════════
#  WELADTI  — One-Click Startup Script
#  Starts Docker backend + Flutter iOS Simulator
# ══════════════════════════════════════════════════════════════════════════════

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
PINK='\033[0;35m'
NC='\033[0m'

print_header() {
  echo ""
  echo -e "${PINK}╔══════════════════════════════════════════╗${NC}"
  echo -e "${PINK}║   🌸  ولادتي — Weladti  🌸               ║${NC}"
  echo -e "${PINK}║   AI Pregnancy Health Platform            ║${NC}"
  echo -e "${PINK}╚══════════════════════════════════════════╝${NC}"
  echo ""
}

check_prerequisites() {
  echo -e "${YELLOW}🔍 Checking prerequisites...${NC}"

  if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker not found. Install from https://docker.com${NC}"
    exit 1
  fi
  echo -e "${GREEN}  ✓ Docker installed${NC}"

  if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter not found. Install from https://flutter.dev${NC}"
    exit 1
  fi
  echo -e "${GREEN}  ✓ Flutter installed${NC}"

  if ! docker info &> /dev/null 2>&1; then
    echo -e "${RED}❌ Docker Desktop is not running. Please start it first.${NC}"
    exit 1
  fi
  echo -e "${GREEN}  ✓ Docker Desktop running${NC}"
}

setup_env() {
  echo -e "\n${YELLOW}⚙️  Setting up environment...${NC}"
  if [ ! -f .env ]; then
    cp .env.example .env
    echo -e "${YELLOW}  📝 .env file created from template${NC}"
    echo -e "${YELLOW}  ⚠️  Add your GEMINI_API_KEY to .env for AI features${NC}"
  else
    echo -e "${GREEN}  ✓ .env already exists${NC}"
  fi
}

start_backend() {
  echo -e "\n${YELLOW}🐳 Starting backend (Docker)...${NC}"
  docker-compose up -d --build
  echo -e "${GREEN}  ✓ Backend starting at http://localhost:8000${NC}"

  echo -e "${YELLOW}  ⏳ Waiting for backend to be ready...${NC}"
  for i in {1..30}; do
    if curl -s http://localhost:8000/health > /dev/null 2>&1; then
      echo -e "${GREEN}  ✅ Backend is ready!${NC}"
      return
    fi
    sleep 2
    echo -n "."
  done
  echo -e "\n${YELLOW}  ⚠️  Backend may still be initializing (training ML model)${NC}"
}

start_flutter() {
  echo -e "\n${YELLOW}📱 Starting Flutter on iOS Simulator...${NC}"
  cd frontend

  echo -e "${YELLOW}  📦 Installing dependencies...${NC}"
  flutter pub get

  # Find available iOS simulator
  SIMULATOR=$(xcrun simctl list devices available | grep -E "iPhone (15|14|13)" | head -1 | awk -F'[()]' '{print $2}')
  if [ -z "$SIMULATOR" ]; then
    SIMULATOR=$(xcrun simctl list devices available | grep iPhone | head -1 | awk -F'[()]' '{print $2}')
  fi

  if [ -z "$SIMULATOR" ]; then
    echo -e "${RED}  ❌ No iOS simulator found. Open Xcode → Simulator first.${NC}"
    echo -e "${YELLOW}  Running on connected device or first available...${NC}"
    flutter run
  else
    echo -e "${GREEN}  ✓ Using simulator: $SIMULATOR${NC}"
    flutter run -d "$SIMULATOR"
  fi
}

show_info() {
  echo -e "\n${PINK}══════════════════════════════════════════${NC}"
  echo -e "${GREEN}🚀 Weladti is starting up!${NC}"
  echo -e ""
  echo -e "  Backend API:   ${YELLOW}http://localhost:8000${NC}"
  echo -e "  API Docs:      ${YELLOW}http://localhost:8000/docs${NC}"
  echo -e "  Health Check:  ${YELLOW}http://localhost:8000/health${NC}"
  echo -e ""
  echo -e "  📝 To add Gemini AI:  Edit .env → GEMINI_API_KEY"
  echo -e "  🛑 To stop backend:   docker-compose down"
  echo -e "${PINK}══════════════════════════════════════════${NC}\n"
}

print_header
check_prerequisites
setup_env
start_backend
show_info
start_flutter
