import router from '@ohos.router';
import { StorageUtil } from '../common/utils/storage/StorageUtil';
import { StorageKeys } from '../common/constants/StorageKeys';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct SearchPage {
  @State keyword: string = '';
  @State searchHistory: string[] = [];
  hotKeywords: string[] = ['华为Mate60', 'iPhone 15', ' MacBook', '空调', '冰箱', '智能手表'];

  aboutToAppear(): void {
    this.loadSearchHistory();
  }

  async loadSearchHistory(): Promise<void> {
    try {
      const storage: StorageUtil = StorageUtil.getInstance();
      const history: string[] | null = await storage.getObject<string[]>(StorageKeys.SEARCH_HISTORY, []);
      this.searchHistory = history ? history : [];
    } catch (e) {
      this.searchHistory = [];
    }
  }

  async saveSearchHistory(word: string): Promise<void> {
    if (!word) {
      return;
    }
    let newHistory: string[] = [word];
    for (let i: number = 0; i < this.searchHistory.length; i++) {
      if (this.searchHistory[i] !== word && newHistory.length < 10) {
        newHistory.push(this.searchHistory[i]);
      }
    }
    this.searchHistory = newHistory;
    try {
      const storage: StorageUtil = StorageUtil.getInstance();
      await storage.setObject<string[]>(StorageKeys.SEARCH_HISTORY, newHistory);
    } catch (e) {
    }
  }

  async clearHistory(): Promise<void> {
    this.searchHistory = [];
    try {
      const storage: StorageUtil = StorageUtil.getInstance();
      await storage.remove(StorageKeys.SEARCH_HISTORY);
    } catch (e) {
    }
    promptAction.showToast({ message: '已清空搜索历史' });
  }

  onSearch(): void {
    const word: string = this.keyword.trim();
    if (!word) {
      promptAction.showToast({ message: '请输入搜索关键词' });
      return;
    }
    this.saveSearchHistory(word);
    router.pushUrl({
      url: 'pages/SearchResultPage',
      params: { keyword: word }
    });
  }

  onHistoryClick(word: string): void {
    this.keyword = word;
    this.onSearch();
  }

  onHotClick(word: string): void {
    this.keyword = word;
    this.onSearch();
  }

  build() {
    Column() {
      // 顶部搜索框
      Row({ space: 8 }) {
        Text('←')
          .fontSize(22)
          .onClick(() => { router.back(); })

        TextInput({ text: this.keyword, placeholder: '搜索商品' })
          .layoutWeight(1)
          .height(36)
          .borderRadius(18)
          .backgroundColor('#F5F5F5')
          .fontSize(14)
          .onChange((value: string) => { this.keyword = value; })
          .onSubmit(() => { this.onSearch(); })

        Text('搜索')
          .fontSize(14)
          .fontColor('#FF4D4F')
          .onClick(() => { this.onSearch(); })
      }
      .width('100%')
      .height(48)
      .padding({ left: 12, right: 12 })
      .backgroundColor(Color.White)
      .alignItems(VerticalAlign.Center)

      Scroll() {
        Column() {
          // 搜索历史
          if (this.searchHistory.length > 0) {
            Row() {
              Text('搜索历史')
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333')
                .layoutWeight(1)
              Text('清空')
                .fontSize(13)
                .fontColor('#999')
                .onClick(() => { this.clearHistory(); })
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 16, bottom: 8 })

            Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(8), cross: LengthMetrics.vp(8) } }) {
              ForEach(this.searchHistory, (word: string) => {
                Text(word)
                  .fontSize(13)
                  .fontColor('#666')
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .borderRadius(14)
                  .backgroundColor('#F5F5F5')
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .onClick(() => { this.onHistoryClick(word); })
              }, (word: string) => word)
            }
            .padding({ left: 16, right: 16, bottom: 16 })
            .width('100%')
          }

          // 热门搜索
          Row() {
            Text('热门搜索')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333')
              .layoutWeight(1)
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16, bottom: 8 })

          Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(8), cross: LengthMetrics.vp(8) } }) {
            ForEach(this.hotKeywords, (word: string, index: number) => {
              Row({ space: 4 }) {
                Text(`${index + 1}`)
                  .fontSize(11)
                  .fontColor(index < 3 ? '#FF4D4F' : '#999')
                  .fontWeight(FontWeight.Bold)
                Text(word)
                  .fontSize(13)
                  .fontColor('#333')
              }
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .borderRadius(14)
              .backgroundColor('#FFF1F0')
              .onClick(() => { this.onHotClick(word); })
            }, (word: string, index: number) => `${word}-${index}`)
          }
          .padding({ left: 16, right: 16, bottom: 16 })
          .width('100%')

          // 空状态
          if (this.searchHistory.length === 0) {
            Column() {
              Text('暂无搜索历史')
                .fontSize(14)
                .fontColor('#999')
                .margin({ top: 60 })
            }
            .width('100%')
          }
        }
        .width('100%')
      }
      .layoutWeight(1)
      .backgroundColor('#FFFFFF')
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}
