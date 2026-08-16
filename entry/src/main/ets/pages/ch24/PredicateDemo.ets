import { router } from '@kit.ArkUI';
import { relationalStore } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

const DB_NAME: string = 'predicate_demo.db';
const TABLE_NAME: string = 'student';

// Chapter 24 §4-§5: a self-contained playground to feel how RdbPredicates builds WHERE conditions.
@Entry
@Component
struct PredicateDemo {
  private store: relationalStore.RdbStore | null = null;
  @State output: string = '点击按钮执行谓词查询';

  aboutToAppear(): void {
    const context = getContext(this) as common.Context;
    const config: relationalStore.StoreConfig = {
      name: DB_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    };
    relationalStore.getRdbStore(context, config).then((store) => {
      this.store = store;
      this.seed();
    });
  }

  // Create table and insert fixed sample rows so results are reproducible.
  private async seed(): Promise<void> {
    const store = this.store;
    if (!store) {
      return;
    }
    await store.executeSql(
      `CREATE TABLE IF NOT EXISTS ${TABLE_NAME} (
        id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, score INTEGER, classId INTEGER)`
    );
    const clearPred = new relationalStore.RdbPredicates(TABLE_NAME);
    await store.delete(clearPred);
    const rows: relationalStore.ValuesBucket[] = [
      { 'name': '小明', 'score': 88, 'classId': 1 },
      { 'name': '小红', 'score': 92, 'classId': 1 },
      { 'name': '小刚', 'score': 55, 'classId': 2 },
      { 'name': '小丽', 'score': 76, 'classId': 2 }
    ];
    await store.batchInsert(TABLE_NAME, rows);
  }

  // Run a predicate query built by `build`, render the result as text.
  private async run(label: string, build: (p: relationalStore.RdbPredicates) => void): Promise<void> {
    const store = this.store;
    if (!store) {
      return;
    }
    const p = new relationalStore.RdbPredicates(TABLE_NAME);
    build(p);
    const rs = await store.query(p, ['name', 'score', 'classId']);
    let text = label + '：\n';
    if (rs.rowCount > 0) {
      rs.goToFirstRow();
      do {
        const name = rs.getString(rs.getColumnIndex('name'));
        const score = rs.getLong(rs.getColumnIndex('score'));
        text += `  ${name} - ${score}分\n`;
      } while (rs.goToNextRow());
    } else {
      text += '  (无结果)\n';
    }
    rs.close(); // MUST close ResultSet
    this.output = text;
  }

  build() {
    Column({ space: 10 }) {
      Text('谓词 RdbPredicates 实战')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 8 })

      Button('equalTo：classId = 1').width('90%').onClick(() => {
        this.run('一班同学', (p) => { p.equalTo('classId', 1); });
      })
      Button('greaterThan：score > 60').width('90%').onClick(() => {
        this.run('及格的同学', (p) => { p.greaterThan('score', 60); });
      })
      Button('like：name 含「小」').width('90%').onClick(() => {
        this.run('名字带「小」', (p) => { p.like('name', '%小%'); });
      })
      Button('between + orderByDesc').width('90%').onClick(() => {
        this.run('60~90分 降序', (p) => { p.between('score', 60, 90).orderByDesc('score'); });
      })
      Button('or 组合：一班 或 及格').width('90%').onClick(() => {
        this.run('一班 或 及格', (p) => { p.equalTo('classId', 1).or().greaterThan('score', 60); });
      })
      Button('分页 limitAs(2)').width('90%').onClick(() => {
        this.run('分数前2名', (p) => { p.orderByDesc('score').limitAs(2); });
      })

      Scroll() {
        Text(this.output).fontSize(14).fontColor('#333')
      }
      .width('90%')
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')
      .padding(12)

      Button('返回').width('90%').onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
