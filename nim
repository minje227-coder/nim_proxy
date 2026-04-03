#!/usr/bin/env bash

# NVIDIA NIM + LiteLLM + Claude Code 통합 관리 스크립트

# .env 파일 로드 (Git Bash 환경)
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

ACTION=${1:-"start"}
API_KEY="${NVIDIA_NIM_API_KEY}"
PROXY_URL="http://localhost:4000"
CONTAINER_NAME="litellm-nim"
CONFIG_PATH="$(pwd)/config.yaml"

function start_proxy() {
    echo "[INFO] LiteLLM Docker 컨테이너 시작 중..."
    
    # 기존 컨테이너 정리
    if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
        echo "[INFO] 기존 컨테이너($CONTAINER_NAME) 삭제 중..."
        docker stop $CONTAINER_NAME >/dev/null 2>&1
        docker rm $CONTAINER_NAME >/dev/null 2>&1
    fi

    # Git Bash/MSYS 경로 변환 방지 및 Windows 절대 경로 추출
    WIN_CONFIG_PATH=$(pwd -W)/config.yaml
    export MSYS_NO_PATHCONV=1

    # Docker 실행
    docker run -d \
      -p 4000:4000 \
      -e NVIDIA_NIM_API_KEY="$API_KEY" \
      -e LITELLM_DATABASE_URL="NONE" \
      -e LITELLM_LOG="INFO" \
      -v "$WIN_CONFIG_PATH:/app/config.yaml" \
      --name $CONTAINER_NAME \
      --restart always \
      docker.litellm.ai/berriai/litellm:main-stable \
      --config /app/config.yaml

    if [ $? -eq 0 ]; then
        echo -e "\n[SUCCESS] 프록시 서버가 포트 4000에서 실행 중입니다."
        echo "테스트: curl http://localhost:4000/v1/models -H 'Authorization: Bearer sk-litellm-local'"
        echo "Claude Code 실행할 때는: ./nim claude"
    else
        echo "[ERROR] Docker 실행 실패!"
    fi
}

function run_claude() {
    echo "[INFO] Claude Code를 NVIDIA NIM 프록시에 연결합니다."
    
    export ANTHROPIC_BASE_URL="$PROXY_URL"
    export ANTHROPIC_API_KEY="sk-litellm-local"
    export ANTHROPIC_MODEL="claude-sonnet-4-6"
    export ANTHROPIC_DEFAULT_OPUS_MODEL="claude-opus-4-6"
    export ANTHROPIC_DEFAULT_SONNET_MODEL="claude-sonnet-4-6"
    export ANTHROPIC_DEFAULT_HAIKU_MODEL="claude-haiku-4-5"

    echo "[INFO] claude 실행 중..."
    shift # ACTION 인자 제거
    claude "$@"
}

case "$ACTION" in
    "start" | "start_proxy")
        start_proxy
        ;;
    "test")
        curl -s http://localhost:4000/v1/models -H "Authorization: Bearer sk-litellm-local" | jq '.data[].id' || echo "[ERROR] 서버 응답 없음"
        ;;
    "claude")
        run_claude "$@"
        ;;
    "stop")
        docker stop $CONTAINER_NAME && docker rm $CONTAINER_NAME
        ;;
    "logs")
        docker logs -f $CONTAINER_NAME
        ;;
    *)
        echo "Usage: $0 {start_proxy|test|claude|stop|logs}"
        ;;
esac
