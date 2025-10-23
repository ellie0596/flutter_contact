# AdSense Fallback Integration Guide

## Flutter WebView 설정 완료 사항

1. **google_mobile_ads 패키지 추가** - pubspec.yaml에 추가 완료
2. **Android 설정** - AndroidManifest.xml에 Google Mobile Ads App ID와 WebView Integration Manager 추가 완료
3. **iOS 설정** - Info.plist에 GADApplicationIdentifier, GADIntegrationManager 및 SKAdNetwork 설정 추가 완료
4. **WebView 통합** - webview_screen.dart에 MobileAds 초기화 및 WebView 등록 완료

## React 코드 수정 가이드

### 1. AdSense 계정 설정
먼저 Google AdSense 계정이 필요합니다:
- https://www.google.com/adsense/ 에서 계정 생성
- 웹사이트 승인 받기
- 광고 단위 생성 후 client ID와 slot ID 획득

### 2. React 컴포넌트 수정사항

#### 주요 변경사항:
```javascript
// 1. useRef 추가
import React, { useEffect, useState, useRef } from 'react'

// 2. 상태 추가
const [showAdsense, setShowAdsense] = useState(false)
const adsenseContainerRef = useRef(null)

// 3. 에러 핸들링 함수 추가
const handleAdError = (errorMessage) => {
    if (errorMessage.toLowerCase().includes('no fill') ||
        errorMessage.toLowerCase().includes('no ad available')) {

        setShowAdsense(true)

        // Flutter WebView에 알림
        if (window.Flutter) {
            window.Flutter.postMessage(JSON.stringify({
                type: 'adError',
                error: 'no fill'
            }))
        }

        loadAdsense()
    }
}

// 4. AdSense 로드 함수
const loadAdsense = () => {
    if (!window.adsbygoogle) {
        const script = document.createElement('script')
        script.src = 'https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-YOUR_CLIENT_ID'
        script.async = true
        script.crossOrigin = 'anonymous'
        script.onload = () => {
            (window.adsbygoogle = window.adsbygoogle || []).push({})
        }
        document.head.appendChild(script)
    } else {
        (window.adsbygoogle = window.adsbygoogle || []).push({})
    }
}
```

### 3. HTML 구조 수정

```jsx
return (
    <div className='mt-10'>
        {/* 원래 광고 표시 */}
        {adResponse && !showAdsense ? (
            <div dangerouslySetInnerHTML={{ __html: adResponse }} />
        ) : null}

        {/* AdSense fallback */}
        {showAdsense ? (
            <div>
                <ins className="adsbygoogle"
                     style={{ display: 'block' }}
                     data-ad-client="ca-pub-YOUR_CLIENT_ID"
                     data-ad-slot="YOUR_SLOT_ID"
                     data-ad-format="auto"
                     data-full-width-responsive="true">
                </ins>
            </div>
        ) : null}
    </div>
)
```

### 4. 중요 설정값 변경

다음 값들을 실제 AdSense 계정 정보로 변경해야 합니다:

1. **AdSense Client ID**:
   - `ca-pub-YOUR_ADSENSE_CLIENT_ID`를 실제 client ID로 변경
   - 예: `ca-pub-1234567890123456`

2. **Ad Slot ID**:
   - `YOUR_AD_SLOT_ID`를 실제 광고 단위 ID로 변경
   - 예: `1234567890`

### 5. 테스트 방법

1. **개발 환경에서 테스트**:
   ```bash
   # React 서버 실행
   npm start
   # http://localhost:3401/test 에서 확인
   ```

2. **Flutter 앱에서 테스트**:
   ```bash
   flutter run
   ```

3. **AdSense 테스트 모드**:
   - 개발 중에는 AdSense 테스트 광고를 사용하는 것을 권장
   - data-ad-client="ca-pub-3940256099942544" (테스트용 ID)
   - data-ad-slot="6300978111" (테스트용 슬롯)

### 6. 주의사항

1. **AdSense 정책 준수**:
   - 한 페이지에 표시할 수 있는 광고 수 제한 확인
   - 콘텐츠 정책 준수
   - 클릭 유도 금지

2. **성능 최적화**:
   - AdSense 스크립트는 한 번만 로드
   - 광고는 필요할 때만 표시

3. **에러 처리**:
   - AdSense 로드 실패 시 대체 콘텐츠 표시
   - 사용자 경험을 해치지 않도록 주의

## Flutter 앱 실행 방법

```bash
# 패키지 설치 (이미 완료됨)
flutter pub get

# iOS 실행
flutter run -d ios

# Android 실행
flutter run -d android
```

## 추가 고려사항

1. **광고 수익 추적**: Google AdSense 대시보드에서 수익 모니터링
2. **A/B 테스팅**: 다양한 광고 형식과 위치 테스트
3. **사용자 경험**: 광고가 콘텐츠를 방해하지 않도록 배치
4. **GDPR/CCPA 준수**: 필요한 경우 사용자 동의 구현

## 문제 해결

### Flutter WebView에서 광고가 표시되지 않을 때:
1. MobileAds 초기화 확인
2. WebView JavaScript 활성화 확인
3. 네트워크 연결 확인
4. AdSense 계정 상태 확인

### React에서 AdSense가 로드되지 않을 때:
1. AdSense 계정 승인 상태 확인
2. 도메인 승인 확인
3. 광고 차단 프로그램 비활성화
4. 콘솔 에러 메시지 확인