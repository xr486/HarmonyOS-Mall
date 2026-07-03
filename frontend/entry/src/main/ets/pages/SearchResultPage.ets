import router from '@ohos.router';
import { ProductService } from '../services/product/ProductService';
import { CategoryService } from '../services/product/CategoryService';
import { Product, Category } from '../common/models';
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
  @State isLoading: boolean = false;
  @State sortType: SortType = 0;
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
      this.brandOptions = [];
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

  applyFiltersAndSort(): void {
    let list: Product[] = this.allResults.slice();
    const minP: number = this.minPrice ? parseInt(this.minPrice, 10) : -1;
    const maxP: number = this.maxPrice ? parseInt(this.maxPrice, 10) : -1;
    if (minP >= 0) {
      list = list.filter((p: Product) => p.price >= minP);
    }
    if (maxP >= 0) {
      list = list.filter((p: Product) => p.price <= maxP);
    }
    if (this.selectedBrands.length > 0) {
      list = list.filter((p: Product) => this.selectedBrands.indexOf(p.brand) >= 0);
    }
    if (this.selectedCategoryId) {
      list = list.filter((p: Product) => p.categoryId === this.selectedCategoryId);
    }
    if (this.ratingFilter === 1) {
      list = list.filter((p: Product) => p.rating >= 4);
    } else if (this.ratingFilter === 2) {
      list = list.filter((p: Product) => p.rating >= 3);
    }
    list = this.applySort(list, this.sortType);
    this.filteredResults = list;
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
          .justifyContent(FlexAlign.Center)
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
        } else if (this.filteredResults.length === 0) {
          Column() {
            Text('未找到相关商品').fontSize(16).fontColor('#999')
            Text(`没有与“${this.keyword}”相关的结果`).fontSize(13).fontColor('#bbb').margin({ top: 8 })
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          Scroll() {
            Column() {
              ForEach(this.filteredResults, (product: Product) => {
                Row({ space: 10 }) {
                  if (product.image) {
                    Image(product.image)
                      .width(100)
                      .height(100)
                      .borderRadius(6)
                      .objectFit(ImageFit.Cover)
                      .alt($r('app.media.app_icon'))
                  } else {
                    Column()
                      .width(100)
                      .height(100)
                      .borderRadius(6)
                      .backgroundColor('#F0F0F0')
                  }

                  Column() {
                    Text(product.name)
                      .fontSize(14)
                      .fontColor('#333')
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
                .margin({ bottom: 8 })
                .onClick(() => { this.onProductClick(product); })
              }, (product: Product) => product.productId)
            }
            .padding({ left: 12, right: 12, top: 4 })
            .width('100%')
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .backgroundColor('#F5F5F5')
        }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
