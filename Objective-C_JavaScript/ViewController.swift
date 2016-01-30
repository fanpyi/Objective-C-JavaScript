
//
//  ViewController.swift
//  Objective-C_JavaScript
//
//  Created by fanpyi on 30/1/16.
//  Copyright © 2016 fanpyi. All rights reserved.
//

import UIKit
import JavaScriptCore
@objc protocol JSObjectiveCDelegate: JSExport {
    func onlinePay(payInfo:String)
    func share(shareInfo: String)
}
class ViewController: UIViewController,UIWebViewDelegate, JSObjectiveCDelegate{

    @IBOutlet weak var webview: UIWebView!
    var jsContext: JSContext?
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = NSBundle.mainBundle().URLForResource("index", withExtension: "html")
        webview.loadRequest(NSURLRequest(URL: url!))
    }
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let url = request.URL {
            if url.scheme == "bridge" {
                print("host=\(url.host!)")
                return false
            }
        }
        return true
    }
    func webViewDidStartLoad(webView: UIWebView) {
        
    }
    func webViewDidFinishLoad(webView: UIWebView) {
        jsContext = webview.valueForKeyPath("documentView.webView.mainFrame.javaScriptContext") as? JSContext
        jsContext?.setObject(self, forKeyedSubscript:"native")
        jsContext?.exceptionHandler = { jsContext,exception in
            print("exception=\(exception)")
        }
        let alert: @convention(block) String -> Void = { alertStr in
            let alertViewController = UIAlertController(title: "callNativeAlert", message: alertStr,preferredStyle:.Alert)
            alertViewController.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (_) -> Void in
                
            }))
            self.presentViewController(alertViewController, animated: true, completion: nil)
            
        }
        jsContext?.setObject(unsafeBitCast(alert, AnyObject.self), forKeyedSubscript: "callNativeAlert")
        let log: @convention(block) String -> Void = { log in
            print("log:\(log)")
        }
        jsContext?.setObject(unsafeBitCast(log, AnyObject.self), forKeyedSubscript: "callNativeLog")
    }
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        
    }
    
    //JSObjectiveCDelegate
    func onlinePay(payInfo: String) {
        print("js call \(__FUNCTION__)")
       let payCallback = jsContext?.objectForKeyedSubscript("payCallback")
       payCallback?.callWithArguments(["it is pay callback fail"])
    }
    func share(shareInfo: String) {
         print("js call \(__FUNCTION__)\n shareInfo=\(shareInfo)")
        let shareCallback = jsContext?.objectForKeyedSubscript("shareCallback")
        shareCallback?.callWithArguments(["it is share callback success"])
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func nativeCallJsWithUIWebviewfunction(sender: AnyObject) {
        let fact = webview.stringByEvaluatingJavaScriptFromString("fact(5)")
        print("通过stringByEvaluatingJavaScriptFromString5的阶乘是:\(fact!)")
    }
    @IBAction func nativeCallJsWithJavaScriptCore(sender: AnyObject) {
         let fact = jsContext?.evaluateScript("fact(5)")
         print("通过JavaScriptCore5的阶乘是:\(fact!.toNumber())")
    }
}

