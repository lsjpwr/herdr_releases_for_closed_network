# Herdr 폐쇄망 설치 미러

[releases.herdr.dev](https://releases.herdr.dev)의 Windows / Linux (x86_64) 빌드 미러입니다. Herdr 앱과 herdr-core는 Apache-2.0 라이선스입니다.

## GitHub만 열린 망

- Windows (PowerShell):
  ```powershell
  curl.exe -fsSL https://raw.githubusercontent.com/lsjpwr/herdr_releases_for_closed_network/main/app/install.ps1 -o $env:TEMP\herdr.ps1; [IO.File]::ReadAllText("$env:TEMP\herdr.ps1") | iex
  ```
- Linux:
  ```sh
  curl -fsSL https://raw.githubusercontent.com/lsjpwr/herdr_releases_for_closed_network/main/app/install.sh | sh
  ```

## 외부망이 전부 막힌 망

1. 인터넷 PC에서 내려받습니다: Windows는 [main.zip](https://github.com/lsjpwr/herdr_releases_for_closed_network/archive/refs/heads/main.zip), Linux는 [main.tar.gz](https://github.com/lsjpwr/herdr_releases_for_closed_network/archive/refs/heads/main.tar.gz)
2. 폐쇄망 PC의 로컬 드라이브로 옮겨 압축을 풉니다 (네트워크 공유 경로는 안 됩니다). 설치 후에도 폴더를 지우지 마세요. Windows 앱이 이 폴더에서 업데이트를 찾습니다.
3. 압축을 푼 폴더 안에서 실행합니다:
   - Windows: `powershell -ExecutionPolicy Bypass -File install-offline.ps1`
   - Linux: `sh install-offline.sh`

업데이트: 새로 내려받은 것으로 폴더를 바꾸고 3번을 다시 실행합니다. 앱과 코어가 함께 업데이트됩니다.

## 미러 갱신 (인터넷 PC, 이 repo의 clone에서)

```powershell
.\mirror.ps1 https://raw.githubusercontent.com/lsjpwr/herdr_releases_for_closed_network/main
git add -A; git commit -m "Mirror Herdr <version>"; git push
```

ARM Linux가 필요하면 `mirror.ps1`의 `$targets`에 `"linux-aarch64"`를 추가합니다.
