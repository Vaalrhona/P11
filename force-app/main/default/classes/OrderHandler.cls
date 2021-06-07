public with sharing class OrderHandler {

    //status can't be set to actif if there's not order related to the account
    public static void preventStatusChange(List<Order> orders){
        List<Order> items = [SELECT ID FROM Order WHERE ID IN (SELECT OrderID FROM OrderItem WHERE OrderID IN :orders)];
        for(Order o: orders){
            if(o.Status=='Actif' && !has(o,items)){
                o.addError('Please add products before setting the status to "Actif".');
            }
        }
    }

    //check if there's still orders related to the account in case of deletion and set the acc to inactive if no order
    public static void checkActiveAccount(List<Order> orders){
        Set<ID> oldIDS = new Set<ID>();
        for(Order o: orders){
            oldIDS.add(o.AccountID);
        }

        List<Order> nbOrders = [SELECT AccountID FROM Order WHERE AccountID IN: oldIDS];
        Set<ID> idsToUpdate = new Set<ID>();
        if(nbOrders.size()==0){
            idsToUpdate.addAll(oldIDS);
        }
        else{
            for(Order o: nbOrders){
                if(!has(o,nbOrders)){
                    idsToUpdate.add(o.AccountID);
                }
            }
        }

        List<Account> accountsToUpdate = [SELECT ID, Active__c FROM Account WHERE ID IN:idsToUpdate];
        for(Account a: accountsToUpdate){
            a.Active__c = false;
        }
        update accountsToUpdate;
    }

    //insert tasks related to accounts in scope
    public static void insertTasks(List<Account> accounts){
        List<Task> tasksToInsert = new List<Task>();
        for(Account a: accounts){
            Task t = new Task(WhatID=a.ID, Subject='Call',TaskSubtype='Call', Status='New',Priority='Normal',IsReminderSet=true,ReminderDateTime=System.today().addDays(5));
            tasksToInsert.add(t);
        }
        insert tasksToInsert;
    }

//killed by death method bc contains doesn't work for some reason
    private static Boolean has(Order order, List<Order> ordersToCompare){ 
        Boolean b = false;
        for(Order o: ordersToCompare){
            if(order.id == o.id){
                b=true;
            }
        }
        return b;
    }
}