import { router } from '@kit.ArkUI';
import { distributedKVStore } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

// Local record shape used by the UI list. Declared as an interface because
// ArkTS strict mode forbids inline object type literals (arkts-no-obj-literals-as-types).
interface KvRecord {
  key: string;
  value: string;
}

// Chapter 26 §1: single-device KV store.
// Same key-value idea as Preferences, but backed by the distributed KV engine,
// so it can later be upgraded to cross-device sync by flipping autoSync.
@Entry
@Component
struct SingleDeviceDemo {
  private kvManager?: distributedKVStore.KVManager;
  private kvStore?: distributedKVStore.SingleKVStore;
  @State ready: boolean = false;
  @State keyInput: string = '';
  @State valueInput: string = '';
  @State records: Array<KvRecord> = [];
  @State getResult: string = '';

  aboutToAppear(): void {
    this.initKV();
  }

  private async initKV(): Promise<void> {
    const context = getContext(this) as common.UIAbilityContext;
    this.kvManager = distributedKVStore.createKVManager({
      context: context,
      bundleName: context.abilityInfo.bundleName
    });
    const options: distributedKVStore.Options = {
      createIfMissing: true,
      encrypt: false,
      backup: false,
      autoSync: false, // single device only; no cross-device sync
      kvStoreType: distributedKVStore.KVStoreType.SINGLE_VERSION,
      securityLevel: distributedKVStore.SecurityLevel.S1
    };
    try {
      this.kvStore = await this.kvManager.getKVStore('single_kv_demo', options) as distributedKVStore.SingleKVStore;
      this.ready = true;
      await this.reload();
    } catch (e) {
      const err = e as BusinessError;
      console.error(`KV init failed: code=${err.code}, message=${err.message}`);
    }
  }

  // Re-read every entry from KV to prove data really persists on disk.
  private async reload(): Promise<void> {
    if (!this.kvStore) {
      return;
    }
    try {
      const entries = await this.kvStore.getEntries('');
      const list: Array<KvRecord> = [];
      for (let i = 0; i < entries.length; i++) {
        const e: distributedKVStore.Entry = entries[i];
        const rec: KvRecord = { key: e.key, value: String(e.value.value) };
        list.push(rec);
      }
      this.records = list;
    } catch (e) {
      const err = e as BusinessError;
      console.error(`getEntries failed: code=${err.code}, message=${err.message}`);
    }
  }

  private async save(): Promise<void> {
    if (!this.kvStore || this.keyInput.trim().length === 0) {
      return;
    }
    await this.kvStore.put(this.keyInput, this.valueInput);
    this.getResult = `已保存: ${this.keyInput} = ${this.valueInput}`;
    this.keyInput = '';
    this.valueInput = '';
    await this.reload();
  }

  // Get a single value by key — demonstrates the get(key) API.
  private async query(): Promise<void> {
    if (!this.kvStore || this.keyInput.trim().length === 0) {
      return;
    }
    try {
      const val = await this.kvStore.get(this.keyInput);
      this.getResult = `${this.keyInput} = ${String(val)}`;
    } catch (e) {
      const err = e as BusinessError;
      this.getResult = `查询失败: ${err.message}`;
    }
  }

  // Delete a single entry by key (standalone button, not just per-item).
  private async deleteByKey(): Promise<void> {
    if (!this.kvStore || this.keyInput.trim().length === 0) {
      return;
    }
    await this.kvStore.delete(this.keyInput);
    this.getResult = `已删除: ${this.keyInput}`;
    this.keyInput = '';
    this.valueInput = '';
    await this.reload();
  }

  private async remove(key: string): Promise<void> {
    if (!this.kvStore) {
      return;
    }
    await this.kvStore.delete(key);
    await this.reload();
  }

  build() {
    Column({ space: 12 }) {
      Text('单设备 KV Store')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 4 })

      if (!this.ready) {
        Text('KV 初始化中…').fontColor('#999')
      }

      Row({ space: 8 }) {
        TextInput({ text: this.keyInput, placeholder: 'key' })
          .layoutWeight(1)
          .onChange((v: string) => { this.keyInput = v; })
        TextInput({ text: this.valueInput, placeholder: 'value' })
          .layoutWeight(1)
          .onChange((v: string) => { this.valueInput = v; })
      }

      Row({ space: 8 }) {
        Button('保存')
          .layoutWeight(1)
          .enabled(this.ready)
          .onClick(() => this.save())
        Button('查询')
          .layoutWeight(1)
          .enabled(this.ready)
          .onClick(() => this.query())
        Button('删除')
          .layoutWeight(1)
          .enabled(this.ready)
          .onClick(() => this.deleteByKey())
      }
      .width('90%')

      if (this.getResult.length > 0) {
        Text(this.getResult)
          .fontSize(14)
          .fontColor('#333')
          .padding(8)
      }

      Text('已存条目（杀掉 App 重进仍会在）')
        .fontSize(13)
        .fontColor('#666')
        .margin({ top: 8 })

      List({ space: 8 }) {
        ForEach(this.records, (item: KvRecord) => {
          ListItem() {
            Row() {
              Column({ space: 2 }) {
                Text(item.key).fontSize(15).fontWeight(FontWeight.Medium)
                Text(item.value).fontSize(13).fontColor('#666')
              }
              Blank()
              Button('删')
                .height(32)
                .onClick(() => this.remove(item.key))
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
          }
        }, (item: KvRecord) => item.key)
      }
      .width('100%')
      .layoutWeight(1)

      Button('返回').width('80%').margin({ top: 8 }).onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
