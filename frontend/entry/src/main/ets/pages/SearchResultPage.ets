import router from '@ohos.router';
import { ProductService } from '../services/product/ProductService';
import { Product } from '../common/models';
import { LazyImage } from '../components/LazyImage';
import promptAction from '@ohos.promptAction';

/**
 * 排序类型：0 综合 | 1 销量 | 2 价格升 | 3 价格降 | 4 评分
 */
type SortType = 0 | 1 | 2 | 3 | 4;

@Entry
@Component
struct SearchResultPage {
  @State keyword: string = '';
  @State allResults: Product[] = [];
  @State displayedResults: Product[] = [];
  @State isLoading: boolean = false;
  @State sortType: SortType = 0;
  @State hasMore: boolean = false;
  private pageSize: number = 10;
  private currentPage: number = 1;
  private sortLabels: string[] = ['综合', '销量', '价格↑', '价格↓', '评分'];

  aboutToAppear(): void {
    const params: Record<string, Object> = router.getParams() as Record<string, Object>;
    if (params && params.keyword) {
      this.keyword = params.keyword as string;
    }
    this.loadResults();
  }

  async loadResults(): Promise<void> {
    const word: string = this.keyword.trim();
    if (!word) {
      promptAction.showToast({ message: '请输入搜索关键词' });
      return;
    }
    this.isLoading = true;
    try {
      const service: ProductService = ProductService.getInstance();
      const list: Product[] = await service.searchProducts(word);
      this.allResults = this.applySort(list, this.sortType);
      this.currentPage = 1;
      this.displayedResults = this.allResults.slice(0, this.pageSize);
      this.hasMore = this.allResults.length > this.pageSize;
    } catch (e) {
      this.allResults = [];
      this.displayedResults = [];
      this.hasMore = false;
    }
    this.isLoading = false;
  }

  applySort(list: Product[], sortType: SortType): Product[] {
    const arr: Product[] = list.slice();
    if (sortType === 1) {
      arr.sort((a: Product, b: Product) => b.salesCount - a.salesCount);
    } else if (sortType === 2) {
      arr.sort((a: Product, b: Product) => a.price - b.price);
    } else if (sortType === 3) {
      arr.sort((a: Product, b: Product) => b.price - a.price);
    } else if (sortType === 4) {
      arr.sort((a: Product, b: Product) => b.rating - a.rating);
    }
    return arr;
  }

  onSortChange(type: SortType): void {
    if (this.sortType === type) {
      return;
    }
    this.sortType = type;
    this.allResults = this.applySort(this.allResults, type);
    this.currentPage = 1;
    this.displayedResults = this.allResults.slice(0, this.pageSize);
    this.hasMore = this.allResults.length > this.pageSize;
  }

  loadMore(): void {
    if (!this.hasMore || this.isLoading) {
      return;
    }
    this.currentPage = this.currentPage + 1;
    const end: number = this.currentPage * this.pageSize;
    this.displayedResults = this.allResults.slice(0, end);
    this.hasMore = this.allResults.length > end;
  }

  // ============ 关键词高亮辅助方法 ============
  getMatchIndex(name: string): number {
    if (!this.keyword) {
      return -1;
    }
    return name.toLowerCase().indexOf(this.keyword.trim().toLowerCase());
  }

  getPrefix(name: string): string {
    const idx: number = this.getMatchIndex(name);
    return idx >= 0 ? name.substring(0, idx) : name;
  }

  getMatch(name: string): string {
    const idx: number = this.getMatchIndex(name);
    if (idx < 0) {
      return '';
    }
    return name.substring(idx, idx + this.keyword.trim().length);
  }

  getSuffix(name: string): string {
    const idx: number = this.getMatchIndex(name);
    if (idx < 0) {
      return '';
    }
    return name.substring(idx + this.keyword.trim().length);
  }

  onProductClick(product: Product): void {
    router.pushUrl({
      url: 'pages/ProductDetailPage',
      params: { productId: product.productId }
    });
  }

  build() {
    Column() {
      // 顶部搜索栏
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
          .onSubmit(() => { this.loadResults(); })

        Text('搜索')
          .fontSize(14)
          .fontColor('#FF4D4F')
          .onClick(() => { this.loadResults(); })
      }
      .width('100%')
      .height(48)
      .padding({ left: 12, right: 12 })
      .backgroundColor(Color.White)
      .alignItems(VerticalAlign.Center)

      // 排序栏
      Row() {
        ForEach(this.sortLabels, (label: string, index: number) => {
          Text(label)
            .fontSize(13)
            .fontColor(this.sortType === index ? '#FF4D4F' : '#666')
            .fontWeight(this.sortType === index ? FontWeight.Bold : FontWeight.Normal)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .padding({ top: 10, bottom: 10 })
            .onClick(() => { this.onSortChange(index as SortType); })
        }, (label: string, index: number) => `${label}-${index}`)
      }
      .width('100%')
      .backgroundColor(Color.White)
      .margin({ bottom: 8 })

      // 结果区域
      if (this.isLoading) {
        Column() {
          LoadingProgress().width(36).height(36)
          Text('搜索中...').fontSize(14).fontColor('#999').margin({ top: 8 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.displayedResults.length === 0) {
        Column() {
          Text('未找到相关商品').fontSize(16).fontColor('#999')
          Text(`没有与“${this.keyword}”相关的结果`).fontSize(13).fontColor('#bbb').margin({ top: 8 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 8 }) {
          ForEach(this.displayedResults, (product: Product) => {
            ListItem() {
              Row({ space: 10 }) {
                LazyImage({
                  src: product.images && product.images.length > 0 ? product.images[0] : '',
                  imgWidth: 100,
                  imgHeight: 100,
                  objectFit: ImageFit.Cover,
                  imgBorderRadius: 6,
                  alt: $r('app.media.app_icon')
                })

                Column() {
                  // 商品名称（关键词高亮）
                  Text() {
                    Span(this.getPrefix(product.name))
                      .fontSize(14)
                      .fontColor('#333')
                      .maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                    if (this.getMatchIndex(product.name) >= 0) {
                      Span(this.getMatch(product.name))
                        .fontSize(14)
                        .fontColor('#FF4D4F')
                        .fontWeight(FontWeight.Bold)
                      Span(this.getSuffix(product.name))
                        .fontSize(14)
                        .fontColor('#333')
                    }
                  }
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .width('100%')

                  if (product.brand) {
                    Text(product.brand)
                      .fontSize(11)
                      .fontColor('#999')
                      .margin({ top: 4 })
                  }

                  Row() {
                    Text(`¥${product.price}`)
                      .fontSize(16)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#FF4D4F')
                      .layoutWeight(1)
                    Text(`已售 ${product.salesCount}`)
                      .fontSize(11)
                      .fontColor('#999')
                  }
                  .width('100%')
                  .margin({ top: 6 })
                  .alignItems(VerticalAlign.Bottom)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                .height(100)
                .justifyContent(FlexAlign.SpaceBetween)
              }
              .width('100%')
              .padding(10)
              .backgroundColor(Color.White)
              .borderRadius(8)
              .onClick(() => { this.onProductClick(product); })
            }
          }, (product: Product) => product.productId)

          // 加载更多 / 到底提示
          ListItem() {
            Row() {
              if (this.hasMore) {
                LoadingProgress().width(20).height(20)
                Text('加载中...').fontSize(12).fontColor('#999').margin({ left: 6 })
              } else {
                Text('— 已经到底了 —').fontSize(12).fontColor('#bbb')
              }
            }
            .width('100%')
            .height(44)
            .justifyContent(FlexAlign.Center)
          }
        }
        .layoutWeight(1)
        .padding({ left: 12, right: 12, top: 4 })
        .scrollBar(BarState.Off)
        .onReachEnd(() => { this.loadMore(); })
        .backgroundColor('#F5F5F5')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
