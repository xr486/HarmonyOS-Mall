import { ProductService } from '../services/product/ProductService';
import { CategoryService } from '../services/product/CategoryService';
import { Product, Category } from '../common/models';
import { ProductCard } from '../components/ProductCard';
import router from '@ohos.router';

@Entry
@Component
struct HomePage {
  @State products: Product[] = [];
  @State categories: Category[] = [];
  @State searchKeyword: string = '';
  @State selectedCategory: string = '全部';
  @State isLoading: boolean = true;

  aboutToAppear(): void {
    this.loadData();
  }

  async loadData(): Promise<void> {
    this.isLoading = true;
    try {
      const catService = CategoryService.getInstance();
      const prodService = ProductService.getInstance();
      const cats: Category[] = await catService.getAllCategories();
      const prods: Product[] = await prodService.getAllProducts();
      this.categories = cats;
      this.products = prods;
    } catch (e) {
      this.products = [];
      this.categories = [];
    }
    this.isLoading = false;
  }

  getFilteredProducts(): Product[] {
    let result: Product[] = this.products;
    if (this.selectedCategory !== '全部') {
      result = result.filter((p: Product) => p.categoryId === this.selectedCategory);
    }
    if (this.searchKeyword) {
      const keyword: string = this.searchKeyword.toLowerCase();
      result = result.filter((p: Product) => p.name.toLowerCase().includes(keyword));
    }
    return result;
  }

  build() {
    Column() {
      Search({ placeholder: '搜索商品', value: this.searchKeyword })
        .searchButton('搜索')
        .width('100%')
        .height(40)
        .backgroundColor('#F0F0F0')
        .borderRadius(20)
        .margin({ left: 12, right: 12, top: 8, bottom: 4 })
        .onSubmit((value: string) => {
          this.searchKeyword = value;
        })
        .onChange((value: string) => {
          this.searchKeyword = value;
        })

      Scroll() {
        Row({ space: 12 }) {
          Text('全部')
            .fontSize(13)
            .fontColor(this.selectedCategory === '全部' ? '#FF4D4F' : '#333')
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .borderRadius(14)
            .backgroundColor(this.selectedCategory === '全部' ? '#FFF1F0' : '#F5F5F5')
            .onClick(() => { this.selectedCategory = '全部'; })

          ForEach(this.categories, (cat: Category) => {
            Text(cat.name)
              .fontSize(13)
              .fontColor(this.selectedCategory === cat.categoryId ? '#FF4D4F' : '#333')
              .padding({ left: 10, right: 10, top: 4, bottom: 4 })
              .borderRadius(14)
              .backgroundColor(this.selectedCategory === cat.categoryId ? '#FFF1F0' : '#F5F5F5')
              .onClick(() => { this.selectedCategory = cat.categoryId; })
          }, (cat: Category) => cat.categoryId)
        }
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .width('100%')
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .height(40)

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(36)
            .height(36)
          Text('加载中...')
            .fontSize(14)
            .fontColor('#999')
            .margin({ top: 8 })
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
        .align(Alignment.TopStart)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
