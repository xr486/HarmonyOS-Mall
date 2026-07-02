import { ProductService } from '../services/product/ProductService';
import { CategoryService } from '../services/product/CategoryService';
import { Product, Category } from '../common/models';
import { ProductCard } from '../components/ProductCard';
import router from '@ohos.router';

type SortType = 'default' | 'price-asc' | 'price-desc' | 'sales' | 'rating';

@Entry
@Component
struct ProductListPage {
  @State products: Product[] = [];
  @State categories: Category[] = [];
  @State selectedCategoryId: string = '';
  @State categoryName: string = '';
  @State sortType: SortType = 'default';
  @State isLoading: boolean = true;

  aboutToAppear(): void {
    const params: Record<string, Object> = router.getParams() as Record<string, Object>;
    if (params && params['categoryId']) {
      this.selectedCategoryId = params['categoryId'] as string;
    }
    if (params && params['categoryName']) {
      this.categoryName = params['categoryName'] as string;
    }
    this.loadData();
  }

  async loadData(): Promise<void> {
    this.isLoading = true;
    try {
      const prodService: ProductService = ProductService.getInstance();
      const catService: CategoryService = CategoryService.getInstance();
      const allProducts: Product[] = await prodService.getAllProducts();
      const allCategories: Category[] = await catService.getAllCategories();
      
      this.products = allProducts;
      this.categories = allCategories.filter((c: Category) => c.parentId);
    } catch (e) {
      this.products = [];
      this.categories = [];
    }
    this.isLoading = false;
  }

  getFilteredProducts(): Product[] {
    let result: Product[] = [...this.products];
    
    if (this.selectedCategoryId) {
      result = result.filter((p: Product) => p.categoryId === this.selectedCategoryId);
    }

    switch (this.sortType) {
      case 'price-asc':
        result.sort((a: Product, b: Product) => a.price - b.price);
        break;
      case 'price-desc':
        result.sort((a: Product, b: Product) => b.price - a.price);
        break;
      case 'sales':
        result.sort((a: Product, b: Product) => b.salesCount - a.salesCount);
        break;
      case 'rating':
        result.sort((a: Product, b: Product) => b.rating - a.rating);
        break;
      default:
        break;
    }
    
    return result;
  }

  build() {
    Column() {
      Row() {
        Text('←')
          .fontSize(22)
          .onClick(() => { router.back(); })
        Text(this.categoryName || '商品列表')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Text('')
          .width(36)
      }
      .width('100%')
      .height(48)
      .padding({ left: 12, right: 12 })
      .backgroundColor(Color.White)

      Scroll() {
        Row({ space: 8 }) {
          Text('全部')
            .fontSize(12)
            .fontColor(this.selectedCategoryId === '' ? '#FF4D4F' : '#333')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .borderRadius(12)
            .backgroundColor(this.selectedCategoryId === '' ? '#FFF1F0' : '#F5F5F5')
            .onClick(() => { this.selectedCategoryId = ''; })

          ForEach(this.categories, (cat: Category) => {
            Text(cat.name)
              .fontSize(12)
              .fontColor(this.selectedCategoryId === cat.categoryId ? '#FF4D4F' : '#333')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(12)
              .backgroundColor(this.selectedCategoryId === cat.categoryId ? '#FFF1F0' : '#F5F5F5')
              .onClick(() => { this.selectedCategoryId = cat.categoryId; })
          }, (cat: Category) => cat.categoryId)
        }
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .width('100%')
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .height(44)
      .backgroundColor(Color.White)

      Row({ space: 16 }) {
        Text('综合')
          .fontSize(13)
          .fontColor(this.sortType === 'default' ? '#FF4D4F' : '#666')
          .onClick(() => { this.sortType = 'default'; })
        Text('价格↑')
          .fontSize(13)
          .fontColor(this.sortType === 'price-asc' ? '#FF4D4F' : '#666')
          .onClick(() => { this.sortType = 'price-asc'; })
        Text('价格↓')
          .fontSize(13)
          .fontColor(this.sortType === 'price-desc' ? '#FF4D4F' : '#666')
          .onClick(() => { this.sortType = 'price-desc'; })
        Text('销量')
          .fontSize(13)
          .fontColor(this.sortType === 'sales' ? '#FF4D4F' : '#666')
          .onClick(() => { this.sortType = 'sales'; })
        Text('评分')
          .fontSize(13)
          .fontColor(this.sortType === 'rating' ? '#FF4D4F' : '#666')
          .onClick(() => { this.sortType = 'rating'; })
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor('#FFFFFF')
      .borderBottomWidth(1)
      .borderBottomColor('#F0F0F0')

      if (this.isLoading) {
        Column() {
          LoadingProgress().width(40).height(40)
          Text('加载中...').fontSize(14).fontColor('#999').margin({ top: 8 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.getFilteredProducts().length === 0) {
        Column() {
          Column() {
            Text('暂无商品')
              .fontSize(16)
              .fontColor('#999')
            Text('换个分类看看吧')
              .fontSize(14)
              .fontColor('#999')
              .margin({ top: 8 })
          }
          .width(120)
          .height(120)
          .backgroundColor('#F5F5F5')
          .borderRadius(60)
          .justifyContent(FlexAlign.Center)
          .margin({ bottom: 16 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
            ForEach(this.getFilteredProducts(), (product: Product) => {
              ProductCard({
                product: product,
                onCardClick: () => {
                  router.pushUrl({
                    url: 'pages/ProductDetailPage',
                    params: { productId: product.productId }
                  });
                }
              })
            }, (product: Product) => product.productId)
          }
          .padding({ left: 8, right: 8, top: 8 })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .backgroundColor('#F5F5F5')
        .onScrollEdge((side: ScrollEdge) => {
          if (side === ScrollEdge.Top) {
            this.loadData();
          }
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
