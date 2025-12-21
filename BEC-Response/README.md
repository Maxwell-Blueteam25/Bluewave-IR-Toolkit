## ☁️ BEC & Cloud Response The toolkit includes post-processing parsers for Business Email Compromise investigations.

- **Location:** `/BEC-Response/`
    
- **Tools:** Custom PowerShell parsers to normalize **Hawk Suite** logs for ingestion into Splunk/Elastic.
    
- **Workflow:**
    
    1. Export logs via Hawk Suite (JSON/CSV).
        
    2. Run `Invoke-HawkParser.ps1` to clean, normalize timestamps, and fix JSON nesting.
        
    3. Ingest into SIEM for analysis.
