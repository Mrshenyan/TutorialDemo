import { formBindingData, FormExtensionAbility, formInfo, formProvider } from '@kit.FormKit'
import { Want } from '@kit.AbilityKit'
import { Ch43CardStore, Ch43Snapshot } from '../ch43data/Ch43CardStore'

interface BizErr { code: number; message: string }

/**
 * Chapter 43 - the widget provider.
 *
 * This class is NOT started by the user. The launcher starts it when a widget
 * instance is added / refreshed / removed, so there is no UIAbility here and no
 * window: its only job is to answer "what should this card look like now".
 *
 * Lifecycle (all called from the launcher side):
 *   onAddForm            -> user dropped the card on the home screen (once)
 *   onUpdateForm         -> periodic refresh in form_config.json
 *   onFormEvent          -> the card sent postCardAction({action:'message'})
 *   onRemoveForm         -> user deleted the card
 *   onAcquireFormState   -> launcher asks "can I even show it?"
 */
export default class Ch43FormAbility extends FormExtensionAbility {
  // MUST be synchronous. Returning a Promise here is a silent no-op and the
  // card renders with its default LocalStorage values forever.
  onAddForm(want: Want): formBindingData.FormBindingData {
    const formId: string = this.readStringParam(want, formInfo.FormParam.IDENTITY_KEY)
    const dimension: number = this.readNumberParam(want, formInfo.FormParam.DIMENSION_KEY, 2)
    console.info(`[ch43] onAddForm formId=${formId} dimension=${dimension}`)

    const snap: Ch43Snapshot = Ch43CardStore.load(this.context)
    return formBindingData.createFormBindingData(Ch43CardStore.toBindingData(snap, dimension))
  }

  // Periodic refresh driven by updateDuration in form_config.json.
  // The framework does NOT render anything for us here - we have to push data
  // back with formProvider.updateForm(formId, ...).
  onUpdateForm(formId: string): void {
    const snap: Ch43Snapshot = Ch43CardStore.load(this.context)
    // Only the changing keys are sent; updateForm merges them into the card's
    // LocalStorage instead of replacing the whole store. That is why
    // `dimension`, injected once in onAddForm, keeps its value.
    this.push(formId, Ch43CardStore.toBindingData(snap), 'onUpdateForm')
  }

  // The card's buttons send postCardAction({ action: 'message', params: {...} }).
  // `message` arrives as the JSON string of those params.
  onFormEvent(formId: string, message: string): void {
    const action: string = this.readAction(message)
    console.info(`[ch43] onFormEvent formId=${formId} action=${action}`)

    if (action === 'add') {
      const snap: Ch43Snapshot = Ch43CardStore.bump(this.context)
      this.push(formId, Ch43CardStore.toBindingData(snap), 'event:add')
    } else if (action === 'reset') {
      const snap: Ch43Snapshot = Ch43CardStore.reset(this.context)
      this.push(formId, Ch43CardStore.toBindingData(snap), 'event:reset')
    }
  }

  onRemoveForm(formId: string): void {
    // No cleanup needed here: the data lives in preferences and stays valid
    // for the next instance the user adds.
    console.info(`[ch43] onRemoveForm formId=${formId}`)
  }

  // Answer "READY" so the launcher renders the card immediately.
  // Returning UNKNOWN / DEFAULT makes some launchers show a placeholder.
  onAcquireFormState(want: Want): formInfo.FormState {
    return formInfo.FormState.READY
  }

  private push(formId: string, data: Record<string, Object>, tag: string): void {
    const binding: formBindingData.FormBindingData = formBindingData.createFormBindingData(data)
    formProvider.updateForm(formId, binding)
      .then(() => {
        console.info(`[ch43] updateForm ok (${tag})`)
      })
      .catch((e: BizErr) => {
        const be: BizErr = e as BizErr
        console.error(`[ch43] updateForm failed (${tag}) [${be.code}] ${be.message}`)
      })
  }

  // postCardAction params arrive as a JSON string, e.g. {"msg":"add"}.
  private readAction(message: string): string {
    try {
      const obj: Record<string, Object> = JSON.parse(message) as Record<string, Object>
      const raw: Object | undefined = obj['msg']
      if (typeof raw === 'string') {
        return raw as string
      }
    } catch (e) {
      // Not JSON - fall through and treat the raw string as the action.
      console.info(`[ch43] message is not JSON: ${message}`)
    }
    return message
  }

  private readStringParam(want: Want, key: string): string {
    const params: Record<string, Object> | undefined = want.parameters
    if (params === undefined) {
      return ''
    }
    const raw: Object | undefined = params[key]
    if (typeof raw === 'string') {
      return raw as string
    }
    return ''
  }

  private readNumberParam(want: Want, key: string, fallback: number): number {
    const params: Record<string, Object> | undefined = want.parameters
    if (params === undefined) {
      return fallback
    }
    const raw: Object | undefined = params[key]
    if (typeof raw === 'number') {
      return raw as number
    }
    return fallback
  }
}
