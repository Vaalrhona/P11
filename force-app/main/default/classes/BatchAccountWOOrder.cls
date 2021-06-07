public with sharing class BatchAccountWOOrder implements Database.Batchable<sObject>{

    //select all accounts without orders or tasks
    public Database.QueryLocator start(Database.BatchableContext BC){
        set<id> taskWhatIDs = new set<id>();
        for(Task t: [SELECT WhatId FROM Task WHERE what.type = 'Account' AND TaskSubType='Call']){
            taskWhatIDs.add(t.whatId);
        }
        Set<ID> orders = new Set<Id>();
        for(Order o: [SELECT ID, AccountID FROM Order]){
            orders.add(o.AccountId);
        }
        return Database.getQueryLocator('SELECT ID FROM Account WHERE (ID NOT IN:orders AND ID NOT IN:taskWhatIDs)');
    }

    public void execute(Database.BatchableContext BC, List<Account> scope){
        OrderHandler.insertTasks(scope);
    }

    public void finish(Database.BatchableContext BC){
    }
}