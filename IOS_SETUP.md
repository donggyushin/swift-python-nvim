# iOS 프로젝트 개발 가이드

## 초기 설정

1. **nvim 재시작** 후 플러그인 자동 설치 대기
2. **xcode-build-server 설치**:
   ```bash
   brew install xcode-build-server
   ```

## iOS 프로젝트에서 사용하기

### 방법 1: xcode-build-server CLI 사용
```bash
cd /path/to/your/ios-project
xcode-build-server config -workspace MyApp.xcworkspace -scheme MyApp
nvim MyApp/ContentView.swift
```

### 방법 2: XcodebuildPicker 사용 (권장)
```bash
cd /path/to/your/ios-project
nvim MyApp/ContentView.swift
```

nvim에서:
1. `:XcodebuildPicker` 실행
2. 프로젝트/워크스페이스 선택
3. 스킴 선택
4. LSP가 자동으로 구성됨

### 3. LSP가 자동으로 시작되며 다음 기능 사용 가능:
- **자동완성**: 사용자 정의 클래스, 구조체, 열거형 모두 지원
- **정의로 이동**: `gd`
- **Hover 정보**: `K`
- **이름 변경**: `<leader>rn`
- **코드 액션**: `<leader>ca`
- **참조 찾기**: `gr`
- **포맷팅**: `<leader>f`

## Xcode 빌드 명령어

- `<leader>xb` - 프로젝트 빌드
- `<leader>xr` - 앱 실행
- `<leader>xs` - 스킴/타겟 선택
- `<leader>xd` - 디바이스 선택
- `<leader>xc` - 코드 커버리지 토글

## 주의사항

1. **프로젝트를 처음 열 때**: SourceKit이 인덱싱하는데 10-30초 정도 소요됩니다.
2. **자동완성이 안되면**:
   - Xcode에서 프로젝트를 한번 빌드하세요 (Cmd+B)
   - nvim을 재시작하세요
3. **Swift Package Manager 프로젝트**: 별도 설정 없이 바로 작동합니다.

## Python 기능

기존 Python 개발 환경은 그대로 유지됩니다:
- Pyright LSP
- Ruff Linter
- Black + isort 포맷터
