public class Defect_ReportHandler {
   @AuraEnabled(cacheable = true)
    public static void assignTechnicianByDefectArea(List<Defect_Report__c> reports)
    {
        System.debug('defect report==========' + reports);
        String defectedItem;
        String defectReportId; 
        for(Defect_Report__c dr: reports)
        {
           defectedItem = dr.Defect_Area__c ;
           defectReportId = dr.Id;
           if(defectedItem != null && defectReportId != null)
           {
            List<Technician__c> allTechs = [SELECT Id, Name, Skil_Level__c FROM Technician__c WHERE Skil_Level__c =: defectedItem];
            System.debug('all technicians==========' + allTechs); 
               if(!allTechs.isEmpty())
                {
                  Defect_Report__c dre = [SELECT Id,Technician__c FROM Defect_Report__c WHERE Id =: defectReportId LIMIT 1];
                  System.debug('defect report==========' + dre);
                if(dre != null)
                 {
                dre.Technician__c = allTechs[0].Id;
                System.debug('updated defect report==========' + dre);
                update dre;
                 }else{
                      System.debug(' no defect report==========' );
                 }
                }else{
                     System.debug(' no technicians there for this defect==========');
                }
           }
            else{
                 System.debug(' no defect report created ==========');
            }
        }
        
    }
}