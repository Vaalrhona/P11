trigger TriggerOnOrder on Order (after delete, before update) {
    if(Trigger.isBefore && Trigger.isUpdate){
        OrderHandler.preventStatusChange(Trigger.new);
    }
    else if(Trigger.isAfter && Trigger.isDelete){
        OrderHandler.checkActiveAccount(Trigger.old);
    }
}