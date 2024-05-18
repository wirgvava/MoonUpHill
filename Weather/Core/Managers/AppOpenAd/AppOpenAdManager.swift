//
//  AppOpenAdManager.swift
//  MoonUpHill
//
//  Created by Konstantine Tsirgvava on 18.05.24.
//

import Foundation
import GoogleMobileAds

class AppOpenAdManager: NSObject {
    var appOpenAd: GADAppOpenAd?
    var isLoadingAd = false
    var isShowingAd = false
    
    static let shared = AppOpenAdManager()
    let adUnitID = Bundle.main.infoDictionary?["GADAppOpenID"] as? String ?? ""
    
    //  MARK: - Load Ad
    private func loadAd() async {
        if isLoadingAd || isAdAvailable() { return }
        isLoadingAd = true
                
        do {
            appOpenAd = try await GADAppOpenAd.load(
                withAdUnitID: adUnitID, request: GADRequest())
            appOpenAd?.fullScreenContentDelegate = self
        } catch {
            print("App open ad failed to load with error: \(error.localizedDescription)")
        }
        isLoadingAd = false
    }
    
    //  MARK: - Show Ad
    func showAdIfAvailable() {
        guard !isShowingAd else { return }
        
        // If the app open ad is not available yet but is supposed to show, load a new ad.
        if !isAdAvailable() {
            Task {
                await loadAd()
            }
            return
        }
        
        if let ad = appOpenAd {
            isShowingAd = true
            ad.present(fromRootViewController: nil)
        }
    }
    
    private func isAdAvailable() -> Bool {
        // Check if ad exists and can be shown.
        return appOpenAd != nil
    }
}

// MARK: - GADFullScreenContentDelegate methods
extension AppOpenAdManager: GADFullScreenContentDelegate {
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("App open ad will be presented.")
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        appOpenAd = nil
        isShowingAd = false
        // Reload an ad.
        Task {
            await loadAd()
        }
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error){
        appOpenAd = nil
        isShowingAd = false
        // Reload an ad.
        Task {
            await loadAd()
        }
    }
}
