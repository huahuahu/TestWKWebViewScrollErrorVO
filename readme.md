# TestWKWebViewScrollErrorVO
Demo to show WKWebView can't scroll when webview size isn't set correctly.  
There is a demo video to display the bug.

## How to repro  
1. Run this project in iPhone XR. 
2. Test scroll the webview to make aure it can scroll.
3. Turn on VO, navigate webview by swiping right, the webview can't scroll.

## The key for the bug
https://github.com/huahuahu/TestWKWebViewScrollErrorVO/blob/6d983813270aa383f0fa69f43e5a22fd9db447f3/TestWebviewScrollVO/ViewController.swift#L78
```
            // The height is 1823.94 in iPhone XR
            // set height to 1823 would cause vo fail to scroll.
            // we need set height to 1824
            webView.heightAnchor.constraint(equalToConstant: 1823)
```
