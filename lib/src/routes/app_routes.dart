import 'package:gsloution_mobile/common/app.dart';
import 'package:gsloution_mobile/common/config/import.dart';
import 'package:gsloution_mobile/frontend/view/product/create/create_product.dart';
import 'package:gsloution_mobile/frontend/view/product/view/product_template_view.dart';
import 'package:gsloution_mobile/frontend/view/sales/sale_order_view.dart';
import 'package:gsloution_mobile/src/authentication/views/signin.dart';
import 'package:gsloution_mobile/src/presentation/screens/add_product/add_product_main_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/add_user/add_user_main_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/analytics/analytics_main_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/authentication/forgot_password_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/authentication/login_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/authentication/contact_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/biller/biller_main_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/biller/biller_sections/create_biller_section.dart';
import 'package:gsloution_mobile/src/presentation/screens/brand/brand_main_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/category/category_main_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/customer/customer_main_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/customer/partner/create/create_partner_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/customer/partner/create/create_partner_screen_simple.dart';
import 'package:gsloution_mobile/src/presentation/screens/customer/partner/partner_map.dart';
import 'package:gsloution_mobile/src/presentation/screens/customer_reports/customer_reports_main_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/dashboard/dashboard_main_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/discount_reports/discount_report_main_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/expense/expense_main_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/expense_category/expense_category_main_Screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/expense_invoice/expense_invoice_main_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/expense_invoice/expense_invoice_sections/add_expense_invoice_section.dart';
import 'package:gsloution_mobile/src/presentation/screens/expense_list/expense_list_main_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/expense_payment/expense_payment_main_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/expense_reports/expense_reports_main_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/invoice/invoice_main_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/invoice/invoice_sections/add_sale_invoice_section.dart';
import 'package:gsloution_mobile/src/presentation/screens/management/management_main_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/notification/notification_main_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/notification/notification_sections/notification_content_section.dart';
import 'package:gsloution_mobile/src/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/payment_reports/payment_reports_main_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/pos_sales/pos_sales_main_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/drafts/draft_sales_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/salesSections/sales_return_section.dart';
import 'package:gsloution_mobile/src/presentation/screens/products/products_main_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/products_reports/products_reports_main_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/profile/profile_main_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/purchase/purchase_main_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/purchase/purchase_sections/purchase_return_section.dart';
import 'package:gsloution_mobile/src/presentation/screens/purchase_invoice/purchase_invoice_main_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/purchase_invoice/purchase_sections/add_purchase_invoice_section.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/purchase_reports/purchase_reports_main_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/reports/report_main_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/sales_main_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/splash_screen/splash_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/stock_reports/stock_reports_main_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/supplier/supplier_main_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/supplier/supplier_sections/create_supplier_section.dart';
import 'package:gsloution_mobile/src/presentation/screens/supplier_reports/supplier_reports_main_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/support/support_main_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/tax_report/tax_report_main_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/unit/unit_management_main_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/user_reports/user_reports_main_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/user_role/user_role_main_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/warehouse/inventory/stock_picking_main_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/warehouse/warehouse_main_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/warehouse/warehouse_sections/add_warehouse_section.dart';
import 'package:gsloution_mobile/src/presentation/screens/warehouse_reports/warehouse_reports_main_screen.dart';
import 'package:gsloution_mobile/src/screen/homepage.dart';
import 'package:gsloution_mobile/src/presentation/screens/payment/payment_main_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/payment/sections/create_payment_section.dart';
import 'package:gsloution_mobile/src/presentation/screens/payment/sections/payment_detail_section.dart';
import 'package:gsloution_mobile/src/presentation/screens/invoice/sections/invoice_detail_section.dart';
import 'package:gsloution_mobile/src/presentation/screens/expense/sections/expense_detail_section.dart';
import 'package:gsloution_mobile/src/presentation/screens/expense/sections/expense_approval_section.dart';

class AppRoutes {
  static const String onboarding = "/onboarding";
  static const String login = "/login";
  static const String contactUs = "/contactUs";
  static const String forgotPassword = "/forgotPassword";
  static const String dashboard = "/dashboard";
  static const String analytics = "/analytics";
  static const String sales = "/sales";
  static const String stockPicking = "/stockpicking";
  static const String posSales = "/posSales";
  static const String purchase = "/purchase";
  static const String products = "/products";
  static const String expense = "/expense";
  static const String customer = "/customer";
  static const String report = "/report";
  static const String management = "/management";
  static const String warehouse = "/warehouse";
  static const String notification = "/notification";
  static const String support = "/support";
  static const String addProduct = "/productList";
  static const String creatProduct = "/createProduct";
  static const String category = "/category";
  static const String brand = "/brand";
  static const String unit = "/unit";
  static const String purchaseReports = "/purchaseReports";
  static const String paymentReports = "/paymentReports";
  static const String productsReports = "/productsReports";
  static const String stockReports = "/stockReports";
  static const String expenseReports = "/expenseReports";
  static const String userReports = "/userReports";
  static const String customerReports = "/customerReports";
  static const String warehouseReports = "/warehouseReports";
  static const String supplierReports = "/supplierReports";
  static const String discountReport = "/discountReport";
  static const String taxReport = "/taxReport";
  static const String profile = "/profile";
  static const String notificationContent = "/notificationContent";
  static const String expenseList = "/expenseList";
  static const String expenseCategory = "/expenseCategory";
  static const String expensePayment = "/expensePayment";
  static const String addWarehouse = "/addWarehouse";
  static const String userRole = "/userRole";
  static const String addUser = "/addUser";
  static const String supplier = "/supplier";
  static const String biller = "/biller";
  static const String addCustomer = "/addCustomer";
  static const String createPartner = "/createPartner";
  static const String createSupplier = "/createSupplier";
  static const String createBiller = "/createBiller";
  static const String purchaseReturn = "/purchaseReturn";
  static const String invoice = "/invoice";
  static const String purchaseInvoice = "/purchaseInvoice";
  static const String expenseInvoice = "/expenseInvoice";
  static const String addSaleInvoice = "/addSaleInvoice";
  static const String addPurchaseInvoice = "/addPurchaseInvoice";
  static const String addExpenseInvoice = "/addExpenseInvoice";
  static const String salesReturn = "/salesReturn";
  static const String splashScreen = "/splashScreen";
  static const String app = '/app';
  static const String homePage = '/homepage';
  static const String product = '/product';
  static const String sale = '/sale';
  static const String settings = '/settings';
  static const String signIn = '/signIn';
  static const String partnerMaps = '/partnerMaps';
  static const String draftSales = '/draftSales';
  static const String payments = '/payments';
  static const String createPayment = '/createPayment';
  static const String paymentDetail = '/paymentDetail';
  static const String invoiceDetail = '/invoiceDetail';
  static const String expenseDetail = '/expenseDetail';
  static const String expenseApproval = '/expenseApproval';

  static final List<GetPage> pages = [
    GetPage(name: app, page: () => App(Get.arguments)),
    GetPage(name: homePage, page: () => const Homepage()),
    GetPage(name: signIn, page: () => const SignIn()),
    GetPage(name: product, page: () => const Products()),
    GetPage(name: creatProduct, page: () => const CreateProducts()),
    GetPage(name: sale, page: () => const SaleOrderView()),
    GetPage(name: onboarding, page: () => const OnboardingScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: contactUs, page: () => const ContactScreen()),
    GetPage(name: dashboard, page: () => const DashboardMainScreen()),
    GetPage(name: forgotPassword, page: () => const ForgotPasswordScreen()),
    GetPage(name: analytics, page: () => const AnalyticsMainScreen()),
    GetPage(name: sales, page: () => const SalesMainScreen()),
    GetPage(name: stockPicking, page: () => const StockPickingMainScreen()),
    GetPage(name: posSales, page: () => const POSSalesMainScreen()),
    GetPage(name: purchase, page: () => const PurchaseMainScreen()),
    GetPage(name: products, page: () => const ProductsMainScreen()),
    GetPage(name: expense, page: () => const ExpenseMainScreen()),
    GetPage(name: customer, page: () => const CustomerMainScreen()),
    GetPage(name: report, page: () => const ReportMainScreen()),
    GetPage(name: management, page: () => const ManagementMainScreen()),
    GetPage(name: warehouse, page: () => const WarehouseMainScreen()),
    GetPage(name: notification, page: () => const NotificationMainScreen()),
    GetPage(name: support, page: () => const SupportMainScreen()),
    GetPage(name: addProduct, page: () => const AddProductMainScreen()),
    GetPage(name: category, page: () => const CategoryMainScreen()),
    GetPage(name: brand, page: () => const BrandMainScreen()),
    GetPage(name: unit, page: () => const UnitManagementMainScreen()),
    GetPage(name: draftSales, page: () => const DraftSalesScreen()),
    GetPage(
      name: purchaseReports,
      page: () => const PurchaseReportsMainScreen(),
    ),
    GetPage(name: paymentReports, page: () => const PaymentReportsMainScreen()),
    GetPage(
      name: productsReports,
      page: () => const ProductsReportsMainScreen(),
    ),
    GetPage(name: stockReports, page: () => const StockReportsMainScreen()),
    GetPage(name: expenseReports, page: () => const ExpenseReportsMainScreen()),
    GetPage(name: userReports, page: () => const UserReportsMainScreen()),
    GetPage(
      name: customerReports,
      page: () => const CustomerReportsMainScreen(),
    ),
    GetPage(
      name: warehouseReports,
      page: () => const WarehouseReportsMainScreen(),
    ),
    GetPage(
      name: supplierReports,
      page: () => const SupplierReportsMainScreen(),
    ),
    GetPage(name: discountReport, page: () => const DiscountReportMainScreen()),
    GetPage(name: taxReport, page: () => const TaxReportMainScreen()),
    GetPage(name: profile, page: () => const ProfileMainScreen()),
    GetPage(
      name: notificationContent,
      page: () => const NotificationContentScreen(),
    ),
    GetPage(name: expenseList, page: () => const ExpenseListMainScreen()),
    GetPage(
      name: expenseCategory,
      page: () => const ExpenseCategoryMainScreen(),
    ),
    GetPage(name: expensePayment, page: () => const ExpensePaymentMainScreen()),
    GetPage(name: addWarehouse, page: () => const AddWarehouseSection()),
    GetPage(name: userRole, page: () => const UserRoleMainScreen()),
    GetPage(name: addUser, page: () => const AddUserMainScreen()),
    GetPage(name: supplier, page: () => const SupplierMainScreen()),
    GetPage(name: biller, page: () => const BillerMainScreen()),
    // GetPage(name: createPartner, page: () => const CreatePartner()),
    GetPage(name: createPartner, page: () => const CreatePartnerScreen()),
    // GetPage(name: createPartner, page: () => const CreatePartnerScreenSimple()),
    GetPage(name: createSupplier, page: () => const CreateSupplierSection()),
    GetPage(name: createBiller, page: () => const CreateBillerSection()),
    GetPage(name: purchaseReturn, page: () => const PurchaseReturnSection()),
    GetPage(name: invoice, page: () => const InvoiceMainScreen()),
    GetPage(
      name: purchaseInvoice,
      page: () => const PurchaseInvoiceMainScreen(),
    ),
    GetPage(name: expenseInvoice, page: () => const ExpenseInvoiceMainScreen()),
    GetPage(name: addSaleInvoice, page: () => const AddSaleInvoiceSection()),
    GetPage(
      name: addPurchaseInvoice,
      page: () => const AddPurchaseInvoiceSection(),
    ),
    GetPage(
      name: addExpenseInvoice,
      page: () => const AddExpenseInvoiceSection(),
    ),
    GetPage(name: salesReturn, page: () => const SalesReturnSection()),
    GetPage(name: splashScreen, page: () => const SplashScreen()),
    GetPage(
      name: partnerMaps,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>;
        return GoogleMapsPartners(
          partners:
              arguments['partners'] as List<PartnerModel>, // قائمة العملاء
          isSearch: arguments['isSearch'] as bool, // قيمة البحث
        );
      },
    ),
    GetPage(name: payments, page: () => const PaymentMainScreen()),
    GetPage(name: createPayment, page: () => const CreatePaymentSection()),
    GetPage(name: paymentDetail, page: () => const PaymentDetailSection()),
    GetPage(name: invoiceDetail, page: () => const InvoiceDetailSection()),
    GetPage(name: expenseDetail, page: () => const ExpenseDetailSection()),
    GetPage(name: expenseApproval, page: () => const ExpenseApprovalSection()),
  ];
}
