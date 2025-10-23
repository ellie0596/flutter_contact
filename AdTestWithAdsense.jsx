import axios from 'axios'
import React, { useEffect, useState, useRef } from 'react'

const AdTest = () => {
    const UNIT_ID = '01K82P639FWGTGDA3YVR5SP7PW'
    const UID = 'ABC'
    const PLATFORM = 'web'
    const LOCALE = 'ko'
    const APP_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBJZCI6IjAxSktDRDlINjU2MkpZNEdTQ0FNM0hWRFAwOjAxSk5aWTJDS1dONllUMDhFNkREWkdLMUE0Iiwia2V5VHlwZSI6MSwiaWF0IjoxNzQxNjA3MjE5LCJleHAiOjI1MzQwMjEyODAwMH0.bbEM9VKIo69Duj36FxIqw-S5qNMUmGhhMCP9datrkRM'

    const [adResponse, setAdResponse] = useState('')
    const [errorMsg, setErrorMsg] = useState('')
    const [showAdsense, setShowAdsense] = useState(false)
    const adsenseContainerRef = useRef(null)

    useEffect(() => {
        const config = {
            method: 'get',
            baseURL: 'https://api-v2-dev.adrop.io',
            url: `/request?unit=${UNIT_ID}&uid=${UID}&pf=${PLATFORM}&lcl=${LOCALE}`,
            headers: {
                'Authorization': APP_KEY
            }
        }

        axios.request(config)
             .then((response) => {
                 console.log('response', response)

                 // Check if there's an error code in the response
                 if (response.data.code && response.data.code !== 0) {
                     const errorMessage = response.data.msg || 'Unknown error occurred'
                     setErrorMsg(errorMessage)
                     handleAdError(errorMessage)
                 } else if (response.data.result && response.data.result.ad) {
                     setAdResponse(response.data.result.ad)
                     setShowAdsense(false)
                 } else {
                     const errorMessage = 'No ad available'
                     setErrorMsg(errorMessage)
                     handleAdError(errorMessage)
                 }
             })
             .catch((error) => {
                 console.log('error', error)
                 let errorMessage = 'Failed to load ad'
                 if (error.response?.data?.msg) {
                     errorMessage = error.response.data.msg
                 }
                 setErrorMsg(errorMessage)
                 handleAdError(errorMessage)
             })
    }, [])

    const handleAdError = (errorMessage) => {
        // Check if it's a "no fill" error
        if (errorMessage.toLowerCase().includes('no fill') ||
            errorMessage.toLowerCase().includes('no ad available')) {

            console.log('No fill error detected, showing AdSense as fallback')
            setShowAdsense(true)

            // Notify Flutter WebView about the no fill error
            if (window.Flutter) {
                window.Flutter.postMessage(JSON.stringify({
                    type: 'adError',
                    error: 'no fill'
                }))
            }

            // Load AdSense script and display ad
            loadAdsense()
        }
    }

    const loadAdsense = () => {
        // Only load AdSense script once
        if (!window.adsbygoogle) {
            const script = document.createElement('script')
            script.src = 'https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-YOUR_ADSENSE_CLIENT_ID'
            script.async = true
            script.crossOrigin = 'anonymous'
            script.onload = () => {
                // Initialize AdSense ad after script loads
                try {
                    (window.adsbygoogle = window.adsbygoogle || []).push({})
                } catch (err) {
                    console.error('AdSense error:', err)
                }
            }
            document.head.appendChild(script)
        } else {
            // Script already loaded, just push the ad
            try {
                (window.adsbygoogle = window.adsbygoogle || []).push({})
            } catch (err) {
                console.error('AdSense error:', err)
            }
        }
    }

    console.log('adResponse', adResponse)
    console.log('showAdsense', showAdsense)

    return (
        <div className='mt-10'>
            {/* Show original ad if available */}
            {adResponse && !showAdsense ? (
                <div
                    dangerouslySetInnerHTML={{ __html: adResponse }}
                />
            ) : null}

            {/* Show AdSense as fallback when no fill */}
            {showAdsense ? (
                <div ref={adsenseContainerRef}>
                    <h3>Sponsored Content</h3>
                    {/* AdSense Display Ad Unit */}
                    <ins className="adsbygoogle"
                         style={{ display: 'block' }}
                         data-ad-client="ca-pub-YOUR_ADSENSE_CLIENT_ID"
                         data-ad-slot="YOUR_AD_SLOT_ID"
                         data-ad-format="auto"
                         data-full-width-responsive="true">
                    </ins>
                </div>
            ) : null}

            {/* Error message for debugging (can be removed in production) */}
            {errorMsg && process.env.NODE_ENV === 'development' ? (
                <div className="p-4 text-yellow-500 border border-yellow-300 rounded bg-yellow-50 mt-4">
                    Debug: {errorMsg}
                </div>
            ) : null}
        </div>
    )
}

export default AdTest