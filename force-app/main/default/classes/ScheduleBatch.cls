public with sharing class ScheduleBatch implements Schedulable{

    public static String sched = '0 00 01 ? * 2#1';

    public void execute(SchedulableContext SC){
        BatchAccountWOOrder batch = new BatchAccountWOOrder();
        Database.executeBatch(batch);
    }

}
