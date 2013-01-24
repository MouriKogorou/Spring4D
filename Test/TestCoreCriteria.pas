unit TestCoreCriteria;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit 
  being tested.

}

interface

{$I sv.inc}

uses
  TestFramework, Spring.Collections, Core.Criteria, Generics.Collections, Core.Interfaces,
  Core.Criteria.Criterion, Core.Criteria.Abstract, uModels, Core.Criteria.Restrictions
  ,Core.Session

  ;

type
  // Test methods for class TCriteria

  TestTCriteria = class(TTestCase)
  private
    FCriteria: ICriteria<TCustomer>;
    FSession: TSession;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Add_Eq;
    procedure AddOrder();
    procedure List_Eq_IsNull();
    procedure List_Like();
    procedure List_Ge_Gt();
    procedure List_LEq_Lt();
    procedure List_In_NotIn();
    procedure List_Property_Eq();
    procedure Page_GEq_OrderDesc();
    procedure List_Or_And();
  end;

implementation

uses
  Core.ConnectionFactory
  ,Core.Criteria.Order
  ,Core.Criteria.Properties
  ,TestSession
  ,SQL.Types
  ,TestConsts
  ;


procedure TestTCriteria.SetUp;
begin
  FSession := TSession.Create(TConnectionFactory.GetInstance(dtSQLite, TestDB));
  FCriteria := FSession.CreateCriteria<TCustomer>;
end;

procedure TestTCriteria.TearDown;
begin
  ClearTable(TBL_PEOPLE);
  ClearTable(TBL_ORDERS);
  FCriteria := nil;
  FSession.Free;
end;

procedure TestTCriteria.Add_Eq;
begin
  FCriteria.Add(TRestrictions.Eq('Name', 'Foo'))
    .Add(TRestrictions.Eq('Age', 42));
  CheckEquals(2, FCriteria.Count);
end;


procedure TestTCriteria.AddOrder;
var
  LCustomers: IList<TCustomer>;
begin
  InsertCustomer(42, 'foo');
  InsertCustomer(110, 'foo');
  FCriteria.Add(TRestrictions.Eq(CUSTNAME, 'foo'))
    .AddOrder(TOrder.Desc(CUSTAGE));
  LCustomers := FCriteria.List();
  CheckEquals(110, LCustomers[0].Age);
  CheckEquals(42, LCustomers[1].Age);
end;

procedure TestTCriteria.List_Eq_IsNull;
var
  LCustomers: IList<TCustomer>;
begin
  LCustomers := FCriteria.Add(TRestrictions.Eq(CUSTNAME, 'Foo'))
    .Add(TRestrictions.Eq(CUSTAGE, 42)).Add(TRestrictions.IsNull(CUSTAVATAR)).List;
  CheckTrue(Assigned(LCustomers));
  CheckEquals(0, LCustomers.Count);
  InsertCustomer(42, 'Foo');
  LCustomers := FCriteria.List;
  CheckEquals(1, LCustomers.Count);
  CheckEquals(42, LCustomers[0].Age);
  CheckEquals('Foo', LCustomers[0].Name);
  CheckEquals(0, LCustomers[0].Orders.Count);
  InsertCustomerOrder(LCustomers[0].ID, 1, 100, 100.59);
  LCustomers := FCriteria.List;
  CheckEquals(1, LCustomers.Count);
  CheckEquals(1, LCustomers[0].Orders.Count);
  CheckEquals(100, LCustomers[0].Orders[0].Order_Status_Code);
end;

procedure TestTCriteria.List_Ge_Gt;
var
  LCustomers: IList<TCustomer>;
begin
  InsertCustomer(42, 'Foo');
  InsertCustomer(50, 'Bar');

  LCustomers := FCriteria.Add(TRestrictions.GEq(CUSTAGE, 42))
    .List;
  CheckEquals(2, LCustomers.Count);
  CheckEquals(42, LCustomers[0].Age);
  CheckEquals(50, LCustomers[1].Age);

  FCriteria.Clear;
  LCustomers := FCriteria.Add(TRestrictions.Gt(CUSTAGE, 42))
    .List;
  CheckEquals(1, LCustomers.Count);
  CheckEquals(50, LCustomers[0].Age);
end;

procedure TestTCriteria.List_In_NotIn;
var
  LCustomers: IList<TCustomer>;
  LAges: TArray<Integer>;
begin
  InsertCustomer(42, 'Foo');
  InsertCustomer(50, 'Bar');
  InsertCustomer(68, 'FooBar');
  InsertCustomer(10, 'Fbar');

  LAges := TArray<Integer>.Create(10, 50);
  LCustomers := FCriteria.Add(TRestrictions.In<Integer>(CUSTAGE, LAges))
    .List;
  CheckEquals(2, LCustomers.Count);
  CheckEquals(50, LCustomers[0].Age);
  CheckEquals(10, LCustomers[1].Age);

  FCriteria.Clear;
  LCustomers := FCriteria.Add(TRestrictions.NotIn<Integer>(CUSTAGE, LAges))
    .List;
  CheckEquals(2, LCustomers.Count);
  CheckEquals(42, LCustomers[0].Age);
  CheckEquals(68, LCustomers[1].Age);

  FCriteria.Clear;
  LCustomers := FCriteria.Add(TRestrictions.In<string>(CUSTNAME, TArray<string>.Create('Bar', 'Fbar')))
    .List;
  CheckEquals(2, LCustomers.Count);
  CheckEquals('Bar', LCustomers[0].Name);
  CheckEquals('Fbar', LCustomers[1].Name);

  FCriteria.Clear;
  LCustomers := FCriteria.Add(TRestrictions.NotIn<string>(CUSTNAME, TArray<string>.Create('Bar', 'Fbar')))
    .List;
  CheckEquals(2, LCustomers.Count);
  CheckEquals('Foo', LCustomers[0].Name);
  CheckEquals('FooBar', LCustomers[1].Name);
end;

procedure TestTCriteria.List_LEq_Lt;
var
  LCustomers: IList<TCustomer>;
begin
  InsertCustomer(42, 'Foo');
  InsertCustomer(50, 'Bar');

  LCustomers := FCriteria.Add(TRestrictions.LEq(CUSTAGE, 50))
    .List;
  CheckEquals(2, LCustomers.Count);
  CheckEquals(42, LCustomers[0].Age);
  CheckEquals(50, LCustomers[1].Age);

  FCriteria.Clear;
  LCustomers := FCriteria.Add(TRestrictions.Lt(CUSTAGE, 50))
    .List;
  CheckEquals(1, LCustomers.Count);
  CheckEquals(42, LCustomers[0].Age);
end;

procedure TestTCriteria.List_Like;
var
  LCustomers: IList<TCustomer>;
begin
  InsertCustomer(42, 'FooBar');
  LCustomers := FCriteria.Add(TRestrictions.Like(CUSTNAME, 'Foo'))
    .List;
  CheckEquals(0, LCustomers.Count);
  FCriteria.Clear;
  FCriteria.Add(TRestrictions.Like(CUSTNAME, 'Foo', mmAnywhere));
  LCustomers := FCriteria.List;
  CheckEquals(1, LCustomers.Count);

  FCriteria.Clear;
  FCriteria.Add(TRestrictions.Like(CUSTNAME, 'Foo', mmStart));
  LCustomers := FCriteria.List;
  CheckEquals(1, LCustomers.Count);

  FCriteria.Clear;
  FCriteria.Add(TRestrictions.Like(CUSTNAME, 'Bar', mmEnd));
  LCustomers := FCriteria.List;
  CheckEquals(1, LCustomers.Count);
end;

procedure TestTCriteria.List_Or_And;
var
  LCustomers: IList<TCustomer>;
  Age: IProperty;
begin
  Age := TProperty.ForName(CUSTAGE);
  InsertCustomer(42, 'Foo');
  InsertCustomer(50, 'Bar');

  LCustomers := FCriteria.Add(TRestrictions.Or(Age.Eq(42), age.Eq(50)))
    .Add(Age.GEq(10))
    .AddOrder(Age.Desc)
    .List;
  CheckEquals(2, LCustomers.Count);
  CheckEquals(50, LCustomers[0].Age);
  CheckEquals(42, LCustomers[1].Age);
end;

procedure TestTCriteria.List_Property_Eq;
var
  LCustomers: IList<TCustomer>;
  Age: IProperty;
begin
  Age := TProperty.ForName(CUSTAGE);
  InsertCustomer(42, 'Foo');
  InsertCustomer(50, 'Bar');

  LCustomers := FCriteria.Add(Age.Eq(42))
    .AddOrder(Age.Desc)
    .List;
  CheckEquals(1, LCustomers.Count);
  CheckEquals(42, LCustomers[0].Age);
end;

procedure TestTCriteria.Page_GEq_OrderDesc;
var
  LPage: IDBPage<TCustomer>;
  Age: IProperty;
  i: Integer;
begin
  Age := TProperty.ForName(CUSTAGE);
  //add 10 customers
  for i := 1 to 10 do
  begin
    InsertCustomer(i, 'Foo', Abs(i/2));
  end;

  LPage := FCriteria.Add(Age.GEq(5))
    .AddOrder(Age.Desc).Page(0, 3);

  CheckEquals(6, LPage.GetTotalItems);
  CheckEquals(2, LPage.GetTotalPages);
  CheckEquals(10, LPage.Items[0].Age);
  CheckEquals(8, LPage.Items[2].Age);
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestTCriteria.Suite);
end.

