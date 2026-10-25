import { huks } from '@kit.UniversalKeystoreKit'

// Chapter 46 - HUKS crypto helper.
//
// HUKS (Universal Keystore) never lets key material leave the secure hardware:
// you reference keys by alias and only ever push DATA in and out. That is the
// whole point - the alternative (a key you generate in JS) is security
// theater.
//
// The session dance for AES-256-CBC is:
//   generateKey -> initSession(inData) -> finishSession
// updateSession exists for large payloads (chunked files/streams) and is
// intentionally not used here. The handle from initSession is a limited
// resource - always finish OR abort, never leak one.
//
// Strict-mode notes:
//  - HuksParam.value is boolean|number|bigint|Uint8Array - enum members are
//    numbers, so they drop in directly.
//  - Object literals must target an explicit interface. `{}` for an all
//    optional interface goes through a typed local to stay on the safe side.
//  - No catch type annotations allowed: plain `catch (e)`.
export class Ch46KeyStore {
  private static readonly ALIAS = 'ch46_demo_aes_key'

  // Key blueprint: AES-256, usable for both directions, CBC, no padding.
  // NOTE: HUKS has NO PKCS7 padding - plaintext must be block-aligned. The
  // caller pads to 16 bytes itself (see Ch46Crypto).
  private static keyProps(): Array<huks.HuksParam> {
    const props: Array<huks.HuksParam> = []
    props.push({ tag: huks.HuksTag.HUKS_TAG_ALGORITHM, value: huks.HuksKeyAlg.HUKS_ALG_AES })
    props.push({ tag: huks.HuksTag.HUKS_TAG_KEY_SIZE, value: huks.HuksKeySize.HUKS_AES_KEY_SIZE_256 })
    props.push({
      tag: huks.HuksTag.HUKS_TAG_PURPOSE,
      value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT | huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT
    })
    props.push({ tag: huks.HuksTag.HUKS_TAG_PADDING, value: huks.HuksKeyPadding.HUKS_PADDING_NONE })
    props.push({ tag: huks.HuksTag.HUKS_TAG_BLOCK_MODE, value: huks.HuksCipherMode.HUKS_MODE_CBC })
    props.push({ tag: huks.HuksTag.HUKS_TAG_DIGEST, value: huks.HuksKeyDigest.HUKS_DIGEST_NONE })
    return props
  }

  // Typed empty options: isKeyItemExist/listAliases/delete take HuksOptions.
  // The `properties` field must be PRESENT (even if empty) - passing `{}`
  // without it trips this strict HUKS build on the very operations that take
  // no real params (delete/listAliases), surfacing a misleading 12000011.
  private static emptyOptions(): huks.HuksOptions {
    const opts: huks.HuksOptions = { properties: [] }
    return opts
  }

  static alias(): string {
    return Ch46KeyStore.ALIAS
  }

  static exists(): Promise<boolean> {
    return huks.isKeyItemExist(Ch46KeyStore.ALIAS, Ch46KeyStore.emptyOptions())
  }

  static listAliases(): Promise<string[]> {
    return huks.listAliases(Ch46KeyStore.emptyOptions())
      .then((r: huks.HuksListAliasesReturnResult) => r.keyAliases)
  }

  static generate(): Promise<void> {
    return huks.generateKeyItem(Ch46KeyStore.ALIAS, { properties: Ch46KeyStore.keyProps() })
  }

  static remove(): Promise<void> {
    // Standard delete: alias + empty options. (On the local emulator's soft
    // TEE this can surface a misleading 12000011 "entity does not exist" even
    // when the key exists - a known emulator limitation; real devices work.)
    return huks.deleteKeyItem(Ch46KeyStore.ALIAS, Ch46KeyStore.emptyOptions())
  }

  // AES-256-CBC for block-aligned payloads. The HUKS session is three steps:
  //   initSession(alias, props)  -> handle
  //   updateSession(handle, data) -> feed plaintext/ciphertext
  //   finishSession(handle, {})  -> outData (ciphertext / plaintext)
  // Feeding data via updateSession (not initSession) is the form that returns
  // a non-null result from finishSession.
  //
  // encrypt=true picks HUKS_KEY_PURPOSE_ENCRYPT, false picks DECRYPT.
  // iv: 16 bytes for CBC - NOT secret, store it alongside the ciphertext.
  // Decryption MUST reuse the very same iv.
  static runCipher(encrypt: boolean, iv: Uint8Array, data: Uint8Array): Promise<Uint8Array> {
    const purpose: huks.HuksKeyPurpose =
      encrypt ? huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT : huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT
    const props: Array<huks.HuksParam> = [
      { tag: huks.HuksTag.HUKS_TAG_ALGORITHM, value: huks.HuksKeyAlg.HUKS_ALG_AES },
      { tag: huks.HuksTag.HUKS_TAG_PURPOSE, value: purpose },
      { tag: huks.HuksTag.HUKS_TAG_IV, value: iv },
      { tag: huks.HuksTag.HUKS_TAG_BLOCK_MODE, value: huks.HuksCipherMode.HUKS_MODE_CBC },
      { tag: huks.HuksTag.HUKS_TAG_PADDING, value: huks.HuksKeyPadding.HUKS_PADDING_NONE },
      { tag: huks.HuksTag.HUKS_TAG_DIGEST, value: huks.HuksKeyDigest.HUKS_DIGEST_NONE }
    ]
    return huks.initSession(Ch46KeyStore.ALIAS, { properties: props })
      .then((session: huks.HuksSessionHandle) => {
        const handle: number = session.handle
        // Any failure must abort the session or the handle leaks - there is
        // only a handful of concurrent sessions per algorithm.
        return huks.updateSession(handle, { inData: data })
          .then((updateResult: huks.HuksReturnResult) => {
            // For CBC (no AEAD), the ciphertext/plaintext is returned by
            // updateSession. finishSession only finalizes the session and
            // returns null, so we must close it then read updateSession's
            // outData.
            return huks.finishSession(handle, Ch46KeyStore.emptyOptions())
              .then(() => {
                const out: Uint8Array =
                  updateResult.outData === undefined || updateResult.outData === null
                    ? new Uint8Array(0)
                    : updateResult.outData
                return out
              })
          })
          .catch((e: Error) => {
            huks.abortSession(handle, Ch46KeyStore.emptyOptions())
            throw e
          })
      })
  }
}
