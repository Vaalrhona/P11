@isTest
public with sharing class TestAccountBatch {

    @isTest
    public static void testAccountBatch(){
        Product2 pd1 = new Product2(Name = 'Chemise Verte longue XYX', Family = 'Chemise', IsActive = true);
        Insert pd1;

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = pd1.Id,
            UnitPrice = 1020,
            IsActive = true
        );
        Insert pbe;

        List<Account> lst_accounts = new List<Account>();
        for(Integer i = 0; i < 200; i++) {
            lst_accounts.add(new Account(Name = 'Test Account ' + i));
        }
        insert lst_accounts;

        List<Order> orders = new List<Order>();
        for(integer i=0; i<50; i++){
            orders.add(new Order(AccountId = lst_accounts[i].Id, EffectiveDate=System.today(), Status='Draft', Pricebook2Id=Test.getStandardPricebookId()));
        }
        insert orders;

        List<Task> tasks = new List<Task>();
        for(integer i=199; i>100; i--){
            tasks.add(new Task(WhatID=lst_accounts[i].ID, Subject='Call Already There',TaskSubtype='Call', Status='New',Priority='Normal',IsReminderSet=true,ReminderDateTime=System.today().addDays(5)));
        }
        insert tasks;

        Test.startTest();
        ScheduleBatch sb = new ScheduleBatch();
        String jobId = System.schedule('testJob', '0 00 01 ? * 2#1', sb);
        sb.execute(null);
        Test.stopTest();

        orders = [SELECT AccountID FROM Order];
        tasks = [SELECT WhatID FROM Task];

        Set<ID> oIDs = new Set<ID>();
        Set<ID> tIDs = new Set<ID>();

        for(Order o: orders){
            oIDs.add(o.AccountID);
        }

        for(Task t: tasks){
            tIDs.add(t.WhatID);
        }

        List<Account> result = [SELECT ID FROM Account WHERE (ID NOT IN:oIDs AND ID NOT IN:tIDs)];
        System.assertEquals(0,result.size());
    }
}
