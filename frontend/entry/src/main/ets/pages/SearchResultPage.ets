import router from '@ohos.router';
import { ProductService } from '../services/product/ProductService';
import { CategoryService } from '../services/product/CategoryService';
import { Product, Category } from '../common/models';
import { LazyImage } from '../components/LazyImage';
import promptAction from '@ohos.promptAction';

/**
 * 排序类型：0 综合 | 1 销量 | 2 价格升 | 3 价格降 | 4 评分
 */
type SortType = 0 | 1 | 2 | 3 | 4;

/**
 * 评分筛选：0 不限 | 1 4分及以上 | 2 3分及以上
 */
type RatingFilter = 0 | 1 | 2;

@Entry
@Component
struct SearchResultPage {
  @State keyword: string = '';
  @State allResults: Product[] = [];
  @State filteredResults: Product[] = [];
  @State displayedResults: Product[] = [];
  @State isLoading: boolean = false;
  @State sortType: SortType = 0;
  @State hasMore: boolean = false;
  // 筛选状态
  @State showFilter: boolean = false;
  @State minPrice: string = '';
  @State maxPrice: string = '';
  @State brandOptions: string[] = [];
  @State selectedBrands: string[] = [];
  @State categoryOptions: Category[] = [];
  @State selectedCategoryId: string = '';
  @State ratingFilter: RatingFilter = 0;
  // 用于面板内临时编辑（确定后才应用）
  @State draftMinPrice: string = '';
  @State draftMaxPrice: string = '';
  @State draftSelectedBrands: string[] = [];
  @State draftSelectedCategoryId: string = '';
  @State draftRatingFilter: RatingFilter = 0;
  private pageSize: number = 10;
  private currentPage: number = 1;
  private sortLabels: string[] = ['综合', '销量', '价格↑', '价格↓', '评分'];
  private ratingLabels: string[] = ['不限', '4分及以上', '3分及以上'];

  aboutToAppear(): void {
    const params: Record<string, Object> = router.getParams() as Record<string, Object>;
    if (params && params.keyword) {
      this.keyword = params.keyword as string;
    }
    this.loadCategories();
    this.loadResults();
  }

  async loadCategories(): Promise<void> {
    try {
      const service: CategoryService = CategoryService.getInstance();
      const list: Category[] = await service.getAllCategories();
      this.categoryOptions = list;
    } catch (e) {
      this.categoryOptions = [];
    }
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
      this.allResults = list;
      // 从结果中提取品牌选项
      this.brandOptions = this.extractBrands(list);
      this.applyFiltersAndSort();
    } catch (e) {
      this.allResults = [];
      this.filteredResults = [];
      this.displayedResults = [];
      this.brandOptions = [];
      this.hasMore = false;
    }
    this.isLoading = false;
  }

  extractBrands(list: Product[]): string[] {
    const set: Set<string> = new Set<string>();
    for (let i: number = 0; i < list.length; i++) {
      const b: string = list[i].brand;
      if (b) {
        set.add(b);
      }
    }
    const arr: string[] = [];
    set.forEach((b: string) => { arr.push(b); });
    return arr;
  }

  /**
   * 应用筛选 + 排序，并重置分页
   */
  applyFiltersAndSort(): void {
    let list: Product[] = this.allResults.slice();
    // 价格区间
    const minP: number = this.minPrice ? parseInt(this.minPrice, 10) : -1;
    const maxP: number = this.maxPrice ? parseInt(this.maxPrice, 10) : -1;
    if (minP >= 0) {
      list = list.filter((p: Product) => p.price >= minP);
    }
    if (maxP >= 0) {
      list = list.filter((p: Product) => p.price <= maxP);
    }
    // 品牌多选
    if (this.selectedBrands.length > 0) {
      list = list.filter((p: Product) => this.selectedBrands.indexOf(p.brand) >= 0);
    }
    // 分类
    if (this.selectedCategoryId) {
      list = list.filter((p: Product) => p.categoryId === this.selectedCategoryId);
    }
    // 评分
    if (this.ratingFilter === 1) {
      list = list.filter((p: Product) => p.rating >= 4);
    } else if (this.ratingFilter === 2) {
      list = list.filter((p: Product) => p.rating >= 3);
    }
    // 排序
    list = this.applySort(list, this.sortType);
    this.filteredResults = list;
    this.currentPage = 1;
    this.displayedResults = list.slice(0, this.pageSize);
    this.hasMore = list.length > this.pageSize;
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
    this.applyFiltersAndSort();
  }

  loadMore(): void {
    if (!this.hasMore || this.isLoading) {
      return;
    }
    this.currentPage = this.currentPage + 1;
    const end: number = this.currentPage * this.pageSize;
    this.displayedResults = this.filteredResults.slice(0, end);
    this.hasMore = this.filteredResults.length > end;
  }

  // ============ 筛选面板交互 ============
  openFilter(): void {
    // 打开时把当前筛选同步到 draft
    this.draftMinPrice = this.minPrice;
    this.draftMaxPrice = this.maxPrice;
    this.draftSelectedBrands = this.selectedBrands.slice();
    this.draftSelectedCategoryId = this.selectedCategoryId;
    this.draftRatingFilter = this.ratingFilter;
    this.showFilter = true;
  }

  cancelFilter(): void {
    this.showFilter = false;
  }

  confirmFilter(): void {
    this.minPrice = this.draftMinPrice;
    this.maxPrice = this.draftMaxPrice;
    this.selectedBrands = this.draftSelectedBrands.slice();
    this.selectedCategoryId = this.draftSelectedCategoryId;
    this.ratingFilter = this.draftRatingFilter;
    this.showFilter = false;
    this.applyFiltersAndSort();
  }

  resetFilter(): void {
    this.draftMinPrice = '';
    this.draftMaxPrice = '';
    this.draftSelectedBrands = [];
    this.draftSelectedCategoryId = '';
    this.draftRatingFilter = 0;
  }

  toggleDraftBrand(brand: string): void {
    const idx: number = this.draftSelectedBrands.indexOf(brand);
    if (idx >= 0) {
      this.draftSelectedBrands.splice(idx, 1);
    } else {
      this.draftSelectedBrands.push(brand);
    }
  }

  isDraftBrandSelected(brand: string): boolean {
    return this.draftSelectedBrands.indexOf(brand) >= 0;
  }

  selectDraftCategory(categoryId: string): void {
    this.draftSelectedCategoryId = this.draftSelectedCategoryId === categoryId ? '' : categoryId;
  }

  selectDraftRating(rating: RatingFilter): void {
    this.draftRatingFilter = rating;
  }

  /**
   * 当前是否有筛选条件生效（用于"筛选"按钮高亮提示）
   */
  hasActiveFilter(): boolean {
    return !!(this.minPrice || this.maxPrice || this.selectedBrands.length > 0
      || this.selectedCategoryId || this.ratingFilter !== 0);
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
    Stack({ alignContent: Alignment.Bottom }) {
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

        // 排序栏 + 筛选入口
        Row() {
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
          .layoutWeight(1)

          Row({ space: 4 }) {
            Text('筛选')
              .fontSize(13)
              .fontColor(this.hasActiveFilter() ? '#FF4D4F' : '#666')
              .fontWeight(this.hasActiveFilter() ? FontWeight.Bold : FontWeight.Normal)
            if (this.hasActiveFilter()) {
              Text('●')
                .fontSize(8)
                .fontColor('#FF4D4F')
            }
          }
          .width(70)
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          .onClick(() => { this.openFilter(); })
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

      // ============ 筛选面板（底部弹起） ============
      if (this.showFilter) {
        Column() {
          // 半透明遮罩
          Column()
            .layoutWeight(1)
            .width('100%')
            .backgroundColor('#66000000')
            .onClick(() => { this.cancelFilter(); })

          // 面板主体
          Column() {
            // 标题栏
            Row() {
              Text('筛选')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333')
                .layoutWeight(1)
              Text('重置')
                .fontSize(13)
                .fontColor('#999')
                .onClick(() => { this.resetFilter(); })
            }
            .width('100%')
            .height(48)
            .padding({ left: 16, right: 16 })
            .alignItems(VerticalAlign.Center)

            Scroll() {
              Column() {
                // 价格区间
                Text('价格区间')
                  .fontSize(14)
                  .fontColor('#333')
                  .fontWeight(FontWeight.Medium)
                  .width('100%')
                  .margin({ bottom: 8 })

                Row({ space: 10 }) {
                  TextInput({ text: this.draftMinPrice, placeholder: '最低价' })
                    .layoutWeight(1)
                    .height(36)
                    .borderRadius(6)
                    .backgroundColor('#F5F5F5')
                    .fontSize(13)
                    .inputType(InputType.Number)
                    .onChange((value: string) => { this.draftMinPrice = value; })

                  Text('-')
                    .fontSize(14)
                    .fontColor('#999')

                  TextInput({ text: this.draftMaxPrice, placeholder: '最高价' })
                    .layoutWeight(1)
                    .height(36)
                    .borderRadius(6)
                    .backgroundColor('#F5F5F5')
                    .fontSize(13)
                    .inputType(InputType.Number)
                    .onChange((value: string) => { this.draftMaxPrice = value; })
                }
                .width('100%')
                .margin({ bottom: 16 })

                // 品牌
                Text('品牌')
                  .fontSize(14)
                  .fontColor('#333')
                  .fontWeight(FontWeight.Medium)
                  .width('100%')
                  .margin({ bottom: 8 })

                if (this.brandOptions.length === 0) {
                  Text('暂无品牌')
                    .fontSize(12)
                    .fontColor('#bbb')
                    .margin({ bottom: 16 })
                } else {
                  Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(8), cross: LengthMetrics.vp(8) } }) {
                    ForEach(this.brandOptions, (brand: string) => {
                      Text(brand)
                        .fontSize(12)
                        .fontColor(this.isDraftBrandSelected(brand) ? '#FFFFFF' : '#666')
                        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                        .borderRadius(14)
                        .backgroundColor(this.isDraftBrandSelected(brand) ? '#FF4D4F' : '#F5F5F5')
                        .onClick(() => { this.toggleDraftBrand(brand); })
                    }, (brand: string) => brand)
                  }
                  .width('100%')
                  .margin({ bottom: 16 })
                }

                // 分类
                Text('分类')
                  .fontSize(14)
                  .fontColor('#333')
                  .fontWeight(FontWeight.Medium)
                  .width('100%')
                  .margin({ bottom: 8 })

                Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(8), cross: LengthMetrics.vp(8) } }) {
                  ForEach(this.categoryOptions, (cat: Category) => {
                    Text(cat.name)
                      .fontSize(12)
                      .fontColor(this.draftSelectedCategoryId === cat.categoryId ? '#FFFFFF' : '#666')
                      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                      .borderRadius(14)
                      .backgroundColor(this.draftSelectedCategoryId === cat.categoryId ? '#FF4D4F' : '#F5F5F5')
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .onClick(() => { this.selectDraftCategory(cat.categoryId); })
                  }, (cat: Category) => cat.categoryId)
                }
                .width('100%')
                .margin({ bottom: 16 })

                // 评分
                Text('评分')
                  .fontSize(14)
                  .fontColor('#333')
                  .fontWeight(FontWeight.Medium)
                  .width('100%')
                  .margin({ bottom: 8 })

                Row({ space: 8 }) {
                  ForEach(this.ratingLabels, (label: string, index: number) => {
                    Text(label)
                      .fontSize(12)
                      .fontColor(this.draftRatingFilter === index ? '#FFFFFF' : '#666')
                      .padding({ left: 14, right: 14, top: 6, bottom: 6 })
                      .borderRadius(14)
                      .backgroundColor(this.draftRatingFilter === index ? '#FF4D4F' : '#F5F5F5')
                      .onClick(() => { this.selectDraftRating(index as RatingFilter); })
                  }, (label: string, index: number) => `${label}-${index}`)
                }
                .width('100%')
                .margin({ bottom: 16 })
              }
              .width('100%')
              .padding({ left: 16, right: 16 })
            }
            .layoutWeight(1)
            .scrollBar(BarState.Off)

            // 底部按钮
            Row({ space: 12 }) {
              Button('取消')
                .layoutWeight(1)
                .height(40)
                .fontSize(14)
                .fontColor('#666')
                .backgroundColor('#F5F5F5')
                .borderRadius(20)
                .onClick(() => { this.cancelFilter(); })

              Button('确定')
                .layoutWeight(1)
                .height(40)
                .fontSize(14)
                .fontColor('#FFFFFF')
                .backgroundColor('#FF4D4F')
                .borderRadius(20)
                .onClick(() => { this.confirmFilter(); })
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 8, bottom: 16 })
          }
          .width('100%')
          .height('70%')
          .backgroundColor(Color.White)
        }
        .width('100%')
        .height('100%')
      }
    }
    .width('100%')
    .height('100%')
  }
}
