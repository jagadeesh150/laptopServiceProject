public with sharing class DefectReportTableController {
    public class DefectReportWrapper {
        @AuraEnabled public String Id { get; set; }
        @AuraEnabled public String CustomerContactName { get; set; }
        @AuraEnabled public String DefectDescription { get; set; }
        @AuraEnabled public String Name { get; set; }
        @AuraEnabled public String DefectSeverity { get; set; }
        @AuraEnabled public String LaptopName { get; set; }
        @AuraEnabled public String TechnicianName { get; set; }
        @AuraEnabled public String Status { get; set; }
    }

    @AuraEnabled(cacheable=true)
    public static List<DefectReportWrapper> getDefectReports(String recordId) {
        List<Defect_Report__c> defectReports;

        if (String.isBlank(recordId)) {
            // Return all defect reports if no recordId is provided
            defectReports = [
                SELECT Id, Customer_Contact__r.Name, Defect_Description__c, Name, Defect_Severity__c, 
                       Laptop__r.Name, Technician__r.Name, Status__c
                FROM Defect_Report__c
            ];
        } else {
            // Check if the recordId is for a Technician and filter by Status "Open"
            defectReports = [
                SELECT Id, Customer_Contact__r.Name, Defect_Description__c, Name, Defect_Severity__c, 
                       Laptop__r.Name, Technician__r.Name, Status__c
                FROM Defect_Report__c
                WHERE (Customer_Contact__c = :recordId OR 
                      (Technician__c = :recordId AND Status__c = 'Open'))
            ];
        }

        return convertToWrapper(defectReports);
    }
    @AuraEnabled
    public static void updateDefectStatus(String defectId, String newStatus) {
        try {
            Defect_Report__c defect = [SELECT Id, Status__c FROM Defect_Report__c WHERE Id = :defectId LIMIT 1];
            defect.Status__c = newStatus;
            update defect;
        } catch (Exception e) {
            throw new AuraHandledException('Error updating defect status: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<DefectReportWrapper> getAllDefectReports() {
        List<Defect_Report__c> defectReports = [
            SELECT Id, Customer_Contact__r.Name, Defect_Description__c, Name, Defect_Severity__c, 
                   Laptop__r.Name, Technician__r.Name, Status__c
            FROM Defect_Report__c
        ];
        return convertToWrapper(defectReports);
    }

    private static List<DefectReportWrapper> convertToWrapper(List<Defect_Report__c> defectReports) {
        List<DefectReportWrapper> defectReportWrappers = new List<DefectReportWrapper>();
        for (Defect_Report__c defect : defectReports) {
            DefectReportWrapper wrapper = new DefectReportWrapper();
            wrapper.Id = defect.Id;
            wrapper.CustomerContactName = defect.Customer_Contact__r != null ? defect.Customer_Contact__r.Name : 'Unknown';
            wrapper.DefectDescription = defect.Defect_Description__c;
            wrapper.Name = defect.Name;
            wrapper.DefectSeverity = defect.Defect_Severity__c;
            wrapper.LaptopName = defect.Laptop__r != null ? defect.Laptop__r.Name : 'Unknown';
            wrapper.TechnicianName = defect.Technician__r != null ? defect.Technician__r.Name : 'Unknown';
            wrapper.Status = defect.Status__c;
            defectReportWrappers.add(wrapper);
        }
        return defectReportWrappers;
    }
}