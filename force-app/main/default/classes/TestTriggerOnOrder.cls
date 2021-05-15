@isTest
public with sharing class TestTriggerOnOrder {

    @TestSetup
    static void makeData(){
        Account acc1 = new Account(Name = 'Test Account 1',Active__c=true);
        insert acc1;

        Account acc2 = new Account(Name = 'Test Account 2',Active__c=true);
        insert acc2;

        Product2 pd1 = new Product2(Name = 'Chemise Verte longue XYX', Family = 'Chemise', IsActive = true);
        Insert pd1;
 
        //Create the PricebookEntry
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = pd1.Id,
            UnitPrice = 1020,
            IsActive = true
        );
        Insert pbe;

        Order o1 = new Order(AccountId = acc1.Id, EffectiveDate=System.today(), Status='Draft', Pricebook2Id=Test.getStandardPricebookId());
        insert o1;

        OrderItem oi1 = new OrderItem (OrderId = o1.Id, PricebookEntryId = pbe.Id, Quantity=10, UnitPrice = 150);
        insert oi1;
        OrderItem oi2 = new OrderItem (OrderId = o1.Id, PricebookEntryId = pbe.Id, Quantity=20, UnitPrice = 1000);
        insert oi2;

        Order o2 = new Order(AccountId = acc1.Id, EffectiveDate=System.today(), Status='Draft', Pricebook2Id=Test.getStandardPricebookId());
        insert o2;

        Order o3 = new Order(AccountId = acc2.Id, EffectiveDate=System.today(), Status='Draft', Pricebook2Id=Test.getStandardPricebookId());
        insert o3;

    }

    @isTest
    public static void testErrorOnStatus(){
        Order o=[SELECT ID, Status FROM Order WHERE ID NOT IN(SELECT OrderID FROM OrderItem) LIMIT 1];
        Boolean exceptionThrown = false;
        try {

            o.Status = 'Actif';
            update o;

        } catch (Exception e) {
            exceptionThrown = true;
            Boolean expectedExceptionThrown =  (e.getMessage().contains('Please add products before setting the status to "Actif".')) ? true : false; 
            System.assertEquals(true, expectedExceptionThrown, e.getMessage()); 
        } 
        System.assertEquals(true, exceptionThrown, 'No exception was thrown');
    }

    @isTest
    public static void testValidStatus(){
        Order o=[SELECT ID, Status FROM Order WHERE ID IN(SELECT OrderID FROM OrderItem)];
        o.Status = 'Actif';
        update o;
        Order result=[SELECT ID, Status FROM Order WHERE ID IN(SELECT OrderID FROM OrderItem)];
        System.assertEquals('Actif', o.Status);
    }

    @isTest
    public static void inactiveAccountWhenOrdersDeleted(){
        List<Order> os=[SELECT ID FROM Order WHERE Account.Name = 'Test Account 1'];
        System.assertEquals(2, os.size());
        delete os;

        os=[SELECT ID FROM Order WHERE Account.Name = 'Test Account 1'];
        System.assertEquals(0, os.size());

        Account result=[SELECT ID,Active__c,(SELECT ID FROM Orders) FROM Account WHERE Name = 'Test Account 1'];
        System.assertEquals(0,result.Orders.size());
        System.assertEquals(false,result.Active__c);
    }
}
