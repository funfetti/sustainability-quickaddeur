public with sharing class sustain_eurHelper {
    // find all EURs not associated with a specific CF. Absolutely terrible performance because it's a demo component. Good luck
    // Thanks to Chris De Gour and Mark Bruchkowsky for preserving my sanity. 
    @AuraEnabled(cacheable=true)
    public static List<SObject> getEurList (string cf){

        // get all existing CFRIs 
        List<sustain_app__ConsumptionReportItem__c> reportItemList = [SELECT sustain_app__EnergyConsumption__c FROM sustain_app__ConsumptionReportItem__c WHERE sustain_app__ConsumptionReport__c = :cf ORDER BY sustain_app__EnergyConsumption__c ASC];

        // create the list of EUR IDs associated to the CFRI
        String fkey;
        List<String> existingForeignKeyList = new List<String>();
        for(sustain_app__ConsumptionReportItem__c item : reportItemList){
            fkey = item.sustain_app__EnergyConsumption__c;
            existingForeignKeyList.add(fkey);
        }

        // get the asset Id AS A STRING
        string asset = [SELECT sustain_app__Asset__c FROM sustain_app__ConsumptionReport__c WHERE Id = :cf LIMIT 1].sustain_app__Asset__c;
        
        System.debug(asset);
        System.debug(existingForeignKeyList);

        //get all EURs associated with the Asset and that is not associated with the CF
        List<sustain_app__EnergyConsumption__c> eurList = [SELECT Id,Name,sustain_app__StartDate__c,sustain_app__EndDate__c FROM sustain_app__EnergyConsumption__c WHERE sustain_app__Asset__c = :asset AND Id NOT IN :existingForeignKeyList];

        return eurList;
    }
     
    // i dont know how how to pass a list of objects into apex from an lwc so none of this works right now 

    //creates a bunch of CFRI junction objects... hopefully
    @AuraEnabled
    public static String createJunctions(List<String> toPair, String cf){
        // create the list im gonna run the dml op against
        List<sustain_app__ConsumptionReportItem__c> cfri = new List<sustain_app__ConsumptionReportItem__c>();

        // create all the junction objects maybe lol
        for (String eur : toPair){
            sustain_app__ConsumptionReportItem__c c = new sustain_app__ConsumptionReportItem__c(
                sustain_app__EnergyConsumption__c = eur, sustain_app__ConsumptionReport__c = cf
            );
            cfri.add(c);
        }
        System.debug(cfri);

        try {  
            insert cfri;
            return cfri.size() + ' records succesfully paired';
        } catch(DmlException e) {
            return 'An unexpected error has occurred: ' + e.getMessage();
        }
    }
}
