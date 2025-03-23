//
//  PhantomService.swift
//  PhantomConnect
//
//  Created by Eric McGary on 6/28/22.
//

import Foundation
import Solana

@available(iOS 10.0, *)
public class PhantomConnectService {
    
    // ============================================================
    // === Internal Static API ====================================
    // ============================================================
    
    // MARK: - Internal Static API
    
    // MARK: Internal Static Properties
    
    static var appUrl: String?
    static var cluster: String?
    static var redirectUrl: String?
    
    // MARK: Internal Static Methods
    
    // ============================================================
    // === Public API =============================================
    // ============================================================
    
    // MARK: - Public API
    
    // MARK: Public Methods
        
    public init(){}
    
    /// This connection request will prompt the user for permission to share their public key, indicating that they are willing to interact further.
    /// - Parameters:
    ///   - publicKey: A public key used for end-to-end encryption. This will be used to generate a shared secret.
    ///   - version: Version of the phatom deeplink api to use. Defaults to `v1`
    /// - SeeAlso:
    ///   - https://docs.phantom.app/integrating/deeplinks-ios-and-android/provider-methods/connect
    public func connect(
        publicKey: Data,
        version: String? = "v1"
    ) throws -> URL {
        
        try checkConfiguration()
        
        guard let url = UrlUtils.format("\(phantomBase)ul/\(version!)/connect", parameters: [
            "app_url": PhantomConnectService.appUrl!,
            "dapp_encryption_public_key": Base58.encode(publicKey.bytes),
            "redirect_link": "\(PhantomConnectService.redirectUrl!)phantom_connect",
            "cluster": "\(PhantomConnectService.cluster!)"
        ]) else {
            throw PhantomConnectError.invalidUrl
        }
        
        return url
                
    }
    
    /// Creates a disconnect phantom universal link
    /// - Parameters:
    ///   - publicKey: A public key used for end-to-end encryption. This will be used to generate a shared secret.
    ///   - nonce: A nonce used for encrypting the request, encoded in base58.
    ///   - payload: base58 encoded string of a JSON object
    ///   - version: Version of the phatom deeplink api to use. Defaults to `v1`
    /// - SeeAlso:
    ///   - https://docs.phantom.app/integrating/deeplinks-ios-and-android/provider-methods/disconnect
    public func disconnect(
        encryptionPublicKey: PublicKey?,
        nonce: String,
        payload: String,
        version: String? = "v1"
    ) throws -> URL {
        
        try checkConfiguration()
        
        guard let encryptionPublicKey = encryptionPublicKey else {
            throw PhantomConnectError.invalidEncryptionPublicKey
        }
        
        guard let url = UrlUtils.format("\(phantomBase)ul/\(version!)/disconnect", parameters: [
            "dapp_encryption_public_key": encryptionPublicKey.base58EncodedString,
            "redirect_link": "\(PhantomConnectService.redirectUrl!)phantom_disconnect",
            "nonce": nonce,
            "payload": payload
        ]) else {
            throw PhantomConnectError.invalidUrl
        }
         
        return url
        
    }
    
    /// Prompt the user for permission to send transactions on their behalf.
    /// - Parameters:
    ///   - publicKey: A public key used for end-to-end encryption. This will be used to generate a shared secret.
    ///   - nonce: A nonce used for encrypting the request, encoded in base58.
    ///   - payload: base58 encoded string of a JSON object
    ///   - version: Version of the phatom deeplink api to use. Defaults to `v1`
    /// - SeeAlso:
    ///   - https://docs.phantom.app/integrating/deeplinks-ios-and-android/provider-methods/signandsendtransaction
    public func signAndSendTransaction(
        encryptionPublicKey: PublicKey?,
        nonce: String,
        payload: String,
        version: String? = "v1"
    ) throws -> URL {
        
        try checkConfiguration()
        
        guard let encryptionPublicKey = encryptionPublicKey else {
            throw PhantomConnectError.invalidEncryptionPublicKey
        }
        
        guard let url = UrlUtils.format("\(phantomBase)ul/\(version!)/signAndSendTransaction", parameters: [
            "dapp_encryption_public_key": encryptionPublicKey.base58EncodedString,
            "redirect_link": "\(PhantomConnectService.redirectUrl!)phantom_sign_and_send_transaction",
            "nonce": nonce,
            "payload": payload
        ]) else {
            throw PhantomConnectError.invalidUrl
        }
        
        return url
        
    }
    
    /// Not implemented yet
    /// - SeeAlso:
    ///   - https://docs.phantom.app/integrating/deeplinks-ios-and-android/provider-methods/signalltransactions
    public func signAllTransactions() throws -> URL? {
        try checkConfiguration()
        assertionFailure("Not implemented")
        return nil
    }

    /// Prompts the user to sign a transaction via Phantom, returning a URL to trigger the Phantom signing deeplink.
    /// This method constructs a deeplink URL that, when opened, prompts the user to sign a transaction in the Phantom wallet.
    /// The app is responsible for broadcasting the signed transaction after receiving it via the redirect link.
    ///
    /// - Parameters:
    ///   - encryptedPayload: A base58-encoded, encrypted payload containing the serialized transaction and session token.
    ///   - nonce: A nonce used for encryption, ensuring the payload’s integrity.
    ///   - phantomEncryptionPublicKey: Phantom’s public key for encryption, obtained from the connect response.
    ///   - version: The version of the Phantom deeplink API to use. Defaults to "v1".
    /// - Returns: A URL that triggers the Phantom signing deeplink.
    /// - Throws: `PhantomConnectError.invalidUrl` if the URL cannot be constructed, or other errors if the configuration is invalid.
    /// - SeeAlso: [Phantom Documentation - signTransaction](https://docs.phantom.app/integrating/deeplinks-ios-and-android/provider-methods/signtransaction)
    public func signTransaction(
        encryptedPayload: String,
        nonce: String,
        phantomEncryptionPublicKey: PublicKey,
        version: String = "v1"
    ) throws -> URL {
        try checkConfiguration()

        guard let url = UrlUtils.format(
            "\(phantomBase)ul/\(version)/signTransaction",
            parameters: [
                "dapp_encryption_public_key": Base58.encode(phantomEncryptionPublicKey.bytes),
                "nonce": nonce,
                "redirect_link": "\(PhantomConnectService.redirectUrl!)phantom_sign_transaction",
                "payload": encryptedPayload
            ]
        ) else {
            throw PhantomConnectError.invalidUrl
        }

        return url
    }
    
    /// Not implemented yet
    /// - SeeAlso:
    /// - https://docs.phantom.app/integrating/deeplinks-ios-and-android/provider-methods/signmessage
    public func signMessage(encryptionPublicKey: PublicKey?,
                            nonce: String,
                            redirect: String,
                            payload: String,
                            version: String? = "v1") throws -> URL {
        try checkConfiguration()
        
        guard let encryptionPublicKey = encryptionPublicKey else {
            throw PhantomConnectError.invalidEncryptionPublicKey
        }
        
        guard let url = UrlUtils.format("\(phantomBase)ul/\(version!)/signMessage", parameters: [
            "dapp_encryption_public_key": encryptionPublicKey.base58EncodedString,
            "redirect_link": "\(PhantomConnectService.redirectUrl!)phantom_sign_message",
            "nonce": nonce,
            "payload": payload
        ]) else {
            throw PhantomConnectError.invalidUrl
        }
        
        return url
    }
    
    // ============================================================
    // === Private API ============================================
    // ============================================================
    
    // MARK: - Private API
    
    // MARK: Private Properties
    
    private let phantomBase = "https://phantom.app/"
    
    // MARK: Private Methods
    
    private func checkConfiguration() throws {
        
        if PhantomConnectService.appUrl == nil ||
            PhantomConnectService.cluster == nil ||
            PhantomConnectService.redirectUrl == nil {
            
            throw PhantomConnectError.invalidConfiguration
            
        }
        
    }
    
}
