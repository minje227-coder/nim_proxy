# NIM Proxy for Claude (via LiteLLM)

This proxy is tuned for Claude-style aliases, not Hermes-native model names.

It exposes Claude-compatible model names such as:
- claude-sonnet-4-6
- claude-opus-4-6
- claude-haiku-4-5
- claude-3-5-sonnet
- claude-3-7-sonnet
- claude-3-5-haiku-20241022

It also exposes a raw NVIDIA NIM model name for direct routing:
- nvidia_nim/minimaxai/minimax-m2.5

## Files
- config.yaml: LiteLLM routing config for NVIDIA NIM
- nim: helper script to start, test, stop, and inspect the proxy
- .env: local secrets file for NVIDIA_NIM_API_KEY and LITELLM_MASTER_KEY

## Setup
1. Put your NVIDIA API key in `.env`:

```env
NVIDIA_NIM_API_KEY=nvapi-your-key-here
LITELLM_MASTER_KEY=sk-litellm-local
```

2. Start the proxy:

```bash
./nim start_proxy
```

3. Test the proxy:

```bash
./nim test
```

## Claude alias mapping

Current alias mapping in `config.yaml`:
- `claude-sonnet-4-6` -> `nvidia_nim/google/gemma-4-31b-it`
- `claude-opus-4-6` -> `nvidia_nim/moonshotai/kimi-k2.5`
- `claude-haiku-4-5` -> `nvidia_nim/minimaxai/minimax-m2.5`
- `claude-3-5-sonnet` -> `nvidia_nim/deepseek-ai/deepseek-v3.1-terminus`
- `claude-3-7-sonnet` -> `nvidia_nim/z-ai/glm5`
- `claude-3-5-haiku-20241022` -> `nvidia_nim/minimaxai/minimax-m2.5`

## Claude config example

Use these environment variables when pointing a Claude-compatible client at this proxy:

```bash
export ANTHROPIC_BASE_URL=http://localhost:4000
export ANTHROPIC_API_KEY=sk-litellm-local
export ANTHROPIC_MODEL=claude-sonnet-4-6
```

You can replace `claude-sonnet-4-6` with any exposed Claude alias from `config.yaml`.
