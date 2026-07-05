import router from '@ohos.router';
import { StorageUtil } from '../common/utils/storage/StorageUtil';
import { StorageKeys } from '../common/constants/StorageKeys';
import { ProductService } from '../services/product/ProductService';
import { Product } from '../common/models';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct SearchPage {
  @State keyword: string = '';
  @State searchHistory: string[] = [];
  @State suggestions: Product[] = [];
  @State showSuggestions: boolean = false;
  private hotKeywords: string[] = ['华为Mate60', 'iPhone 15', ' MacBook', '空调', '冰箱', '智能手表'];
  private debounceId: number = -1;
  private lastRequestKeyword: string = '';

  aboutToAppear(): void {
    this.loadSearchHistory();
  }

  aboutToDisappear(): void {
    if (this.debounceId !== -1) {
      clearTimeout(this.debounceId);
      this.debounceId = -1;
    }
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
    this.showSuggestions = false;
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

  /**
   * 输入框内容变化：防抖 400ms 触发联想请求
   */
  onInputChange(value: string): void {
    this.keyword = value;
    if (this.debounceId !== -1) {
      clearTimeout(this.debounceId);
      this.debounceId = -1;
    }
    const trimmed: string = value.trim();
    if (!trimmed) {
      this.suggestions = [];
      this.showSuggestions = false;
      return;
    }
    this.debounceId = setTimeout(() => {
      this.fetchSuggestions(trimmed);
    }, 400);
  }

  async fetchSuggestions(keyword: string): Promise<void> {
    this.lastRequestKeyword = keyword;
    try {
      const service: ProductService = ProductService.getInstance();
      const list: Product[] = await service.searchSuggestions(keyword, 5);
      // 只在关键词未继续变化时更新，避免乱序
      if (this.lastRequestKeyword === keyword) {
        this.suggestions = list;
        this.showSuggestions = list.length > 0;
      }
    } catch (e) {
      this.suggestions = [];
      this.showSuggestions = false;
    }
  }

  /**
   * 点击建议项：以商品名作为关键词搜索
   */
  onSuggestionClick(product: Product): void {
    this.keyword = product.name;
    this.showSuggestions = false;
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
          .onChange((value: string) => { this.onInputChange(value); })
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

      // 联想建议下拉
      if (this.showSuggestions && this.suggestions.length > 0) {
        Column() {
          ForEach(this.suggestions, (product: Product) => {
            Row() {
              Text('🔍')
                .fontSize(14)
                .fontColor('#999')
              Text(product.name)
                .fontSize(14)
                .fontColor('#333')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .layoutWeight(1)
                .margin({ left: 8 })
              if (product.brand) {
                Text(product.brand)
                  .fontSize(11)
                  .fontColor('#999')
              }
            }
            .width('100%')
            .height(44)
            .padding({ left: 16, right: 16 })
            .alignItems(VerticalAlign.Center)
            .onClick(() => { this.onSuggestionClick(product); })
          }, (product: Product) => product.productId)
        }
        .width('100%')
        .backgroundColor(Color.White)
        .borderRadius({ bottomLeft: 8, bottomRight: 8 })
      }

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

            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.searchHistory, (word: string) => {
                Text(word)
                  .fontSize(13)
                  .fontColor('#666')
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .margin({ right: 8, bottom: 8 })
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

          Flex({ wrap: FlexWrap.Wrap }) {
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
              .margin({ right: 8, bottom: 8 })
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
      .visibility(this.showSuggestions ? Visibility.None : Visibility.Visible)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}
