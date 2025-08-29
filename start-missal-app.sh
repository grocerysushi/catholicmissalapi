#!/bin/bash

# Catholic Missal App Startup Script
# This script starts both the API backend and React frontend

echo "🙏 Starting Catholic Missal App..."
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if required dependencies are installed
echo -e "${YELLOW}Checking dependencies...${NC}"

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python 3 is not installed. Please install Python 3.8 or higher.${NC}"
    exit 1
fi

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js is not installed. Please install Node.js 16 or higher.${NC}"
    exit 1
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo -e "${RED}❌ npm is not installed. Please install npm.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ All dependencies are installed${NC}"

# Function to cleanup background processes
cleanup() {
    echo -e "\n${YELLOW}Shutting down services...${NC}"
    if [[ ! -z "$API_PID" ]]; then
        kill $API_PID 2>/dev/null
        echo -e "${GREEN}✅ API server stopped${NC}"
    fi
    if [[ ! -z "$FRONTEND_PID" ]]; then
        kill $FRONTEND_PID 2>/dev/null
        echo -e "${GREEN}✅ Frontend server stopped${NC}"
    fi
    echo -e "${GREEN}🙏 Catholic Missal App stopped gracefully${NC}"
    exit 0
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM

# Start the API backend
echo -e "${YELLOW}Starting Catholic Missal API...${NC}"
cd "$(dirname "$0")"

# Install Python dependencies if needed
if [ ! -d "venv" ]; then
    echo -e "${YELLOW}Creating Python virtual environment...${NC}"
    python3 -m venv venv
fi

# Activate virtual environment
source venv/bin/activate

# Install/update Python dependencies
pip install -q -r requirements.txt

# Start the API server in the background
python run_dev.py &
API_PID=$!

# Wait a bit for the API to start
sleep 3

# Check if API is running
if ! curl -s http://localhost:8000/api/v1/info > /dev/null; then
    echo -e "${RED}❌ Failed to start API server${NC}"
    kill $API_PID 2>/dev/null
    exit 1
fi

echo -e "${GREEN}✅ API server started on http://localhost:8000${NC}"

# Start the React frontend
echo -e "${YELLOW}Starting React frontend...${NC}"
cd missal-app

# Install Node.js dependencies if needed
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}Installing frontend dependencies...${NC}"
    npm install
fi

# Start the frontend server in the background
npm start &
FRONTEND_PID=$!

# Wait a bit for the frontend to start
sleep 5

echo -e "${GREEN}✅ Frontend started on http://localhost:3000${NC}"
echo ""
echo -e "${GREEN}🎉 Catholic Missal App is now running!${NC}"
echo ""
echo "📱 Frontend: http://localhost:3000"
echo "🔌 API: http://localhost:8000"
echo "📚 API Docs: http://localhost:8000/docs"
echo ""
echo -e "${YELLOW}Press Ctrl+C to stop both servers${NC}"
echo ""

# Keep the script running and wait for user to stop
wait