codeunit 50150 "Demo Utils"
{
    procedure ValidateDirectPrinter(DirectPrinterName: Text; LocalPrinterName: Text)
    var
        LocalPrinter: Record "ForNAV Local Printer";
    begin
        // Check local printer exists
        if (not LocalPrinter.Get(directPrinterName)) then begin
            LocalPrinter.Init();
            LocalPrinter."Cloud Printer Name" := CopyStr(directPrinterName, 0, MaxStrLen(LocalPrinter."Cloud Printer Name"));
            LocalPrinter."Local Printer Name" := CopyStr(LocalPrinterName, 0, MaxStrLen(LocalPrinter."Local Printer Name"));
            LocalPrinter.Paperkind := LocalPrinter.Paperkind::Custom;
            LocalPrinter.Unit := LocalPrinter.Unit::PT;
            LocalPrinter.Insert(true);
        end;
        LocalPrinter.IsPrintService := true;
        LocalPrinter."Initial Job Status" := LocalPrinter."Initial Job Status"::Ready;
        LocalPrinter.Modify(true);
    end;
}