page 50150 "Print PDF"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;

    actions
    {
        area(Processing)
        {
            action(PrintPdfFromBase64)
            {
                ApplicationArea = All;
                Caption = 'Print PDF from BASE64';
                Image = Print;
                ToolTip = 'Create a print job on the direct print queue. PDF stored in BASE64 string.';

                trigger OnAction()
                var
                    DirPrtQueue: Record "ForNAV DirPrt Queue";
                    Base64Convert: Codeunit "Base64 Convert";
                    DemoUtils: Codeunit "Demo Utils";
                    TempBlob: Codeunit "Temp Blob";
                    pdfInStream: InStream;
                    pdfOutStream: OutStream;
                    directPrinterName: Text[250];
                begin
                    directPrinterName := 'Label Printer';

                    // Check local printer exists
                    DemoUtils.ValidateDirectPrinter(directPrinterName, 'Canon Generic Plus PCL6');

                    // Get PDF stored base64 string
                    TempBlob.CreateOutStream(pdfOutStream);
                    Base64Convert.FromBase64(GetSamplePdfBase64(), pdfOutStream);

                    // Create an InStream with the PDF
                    TempBlob.CreateInStream(pdfInStream);

                    // Create a print job on the print queue
                    DirPrtQueue.Create('DHL Express', directPrinterName, pdfInStream, DirPrtQueue.ContentType::PDF);

                    Message('Print job created on direct print queue.');
                end;
            }
            action(PrintPdfFromBlob)
            {
                ApplicationArea = All;
                Caption = 'Print PDF from BLOB';
                Image = Print;
                ToolTip = 'Create a print job on the direct print queue. PDF stored in a BLOB.';

                trigger OnAction()
                var
                    DirPrtQueue: Record "ForNAV DirPrt Queue";
                    FileStorage: Record "ForNAV File Storage";
                    DemoUtils: Codeunit "Demo Utils";
                    pdfInStream: InStream;
                    directPrinterName: Text[250];
                    storageId: Code[20];
                begin
                    directPrinterName := 'Label Printer';
                    storageId := 'FORNAV.DEMO.PRINTPDF';

                    // Check local printer exists
                    DemoUtils.ValidateDirectPrinter(directPrinterName, 'Canon Generic Plus PCL6');

                    // if not FileStorage.Get('', 'PDF') then begin
                    //     FileStorage.Init();
                    //     FileStorage.Data.CreateInStream(dataInStr);
                    //     FileStorage.Code := storageId;
                    //     FileStorage.Insert();
                    // end;

                    // Get PDF from File Storage table
                    if not FileStorage.Get(storageId, 'PDF') then
                        Error('Insert a PDF in the File Storage with code FORNAV.DEMO.PRINTPDF and type PDF first.');
                    FileStorage.CalcFields(FileStorage.Data);

                    // Check if there is data in the file storage record
                    if not FileStorage.Data.HasValue then
                        Error('There is not data in the file storage record.');

                    // Create an InStream with the PDF
                    FileStorage.Data.CreateInStream(pdfInStream);

                    // Create a print job on the print queue
                    DirPrtQueue.Create('BLOB from ForNAV File Storage', 'Label Printer', pdfInStream, DirPrtQueue.ContentType::PDF);

                    Message('Print job created on direct print queue.');
                end;
            }

            action(PrintCopies)
            {
                ApplicationArea = All;
                Caption = 'Print PDF with 2 copies';
                Image = Print;
                ToolTip = 'Create a print job with copies set to 2 on the direct print queue. PDF stored in BASE64 string.';

                trigger OnAction()
                var
                    DirPrtQueue: Record "ForNAV DirPrt Queue";
                    LocalPrinter: Record "ForNAV Local Printer";
                    Base64Convert: Codeunit "Base64 Convert";
                    TempBlob: Codeunit "Temp Blob";
                    DemoUtils: Codeunit "Demo Utils";
                    pdfInStream: InStream;
                    pdfOutStream: OutStream;
                    directPrinterName: Text;
                    printerSettings: Text;
                    printerSettingsObj: JsonObject;
                begin
                    // Get printer settings
                    directPrinterName := 'Office';
                    DemoUtils.ValidateDirectPrinter(directPrinterName, 'Bullzip PDF Printer');
                    LocalPrinter.Get(directPrinterName);
                    printerSettingsObj := LocalPrinter.PrinterSetting();
                    printerSettingsObj.Replace('Copies', 2);
                    printerSettingsObj.WriteTo(printerSettings);

                    // Get PDF stored base64 string
                    TempBlob.CreateOutStream(pdfOutStream);
                    Base64Convert.FromBase64(GetSamplePdfBase64(), pdfOutStream);

                    // Create an InStream with the PDF
                    TempBlob.CreateInStream(pdfInStream);

                    // Create a print job on the print queue
                    DirPrtQueue.Create(0, LocalPrinter."Cloud Printer Name", LocalPrinter."Local Printer Name", pdfInStream, printerSettings, 'Test with copies', DirPrtQueue.ContentType::PDF);

                    Message('Print job created on direct print queue.');
                end;
            }
        }
    }

    local procedure GetSamplePdfBase64(): Text
    var
        base64: Text;
    begin
        base64 :=
            'JVBERi0xLjcKJeLjz9MKNiAwIG9iago8PC9GaWx0ZXIvRmxhdGVEZWNvZGUvTGVuZ3RoIDY5OD4+' +
            'c3RyZWFtCnicpZbNbhMxEMfvfgo/wdQz9vhDQj0gKOIIROJcQoOEKKi98PqMP3az2djbkDZyY2fH' +
            'npnf/O31k0KdP88/lNEGjPxZTTEBWm09QbT6+UEd1Cf1tLS0xoKVkXPAQXMCXtoZ8FYbjVSMjst8' +
            'Vb/l8dudurlDLQ896d1B+aQtIiDr3fcchHzExxtjPN3ufqr3O1n0xH3zuh2DtUC2LIYJktfzpAjR' +
            '6/2juvn4iPrdn3VmZAh8nBCkBITHVQ0gcVm09sgA5/8euK55110TPWbfE9YEkvIZLfIBYujTIl2i' +
            'FljVGhMB+jUv+mYMk7QozRvj5NuxtL20Q26nPC9wLGUqv4rnFIGcxoAQ4tozimdK0sQj3kuz0lz+' +
            'vV9BQYIBvCznbE7METB1BFSLeBkSNhDOJEShYsg4OFQUjPLtFuOMDLtotgJYoGkRUATr1hEIiYKF' +
            'DiMxM1B8gQczJLwcSDXvE7GhZRwqhSyMHKTFJhzTRJP7XJ9le5eanW2CyuLyE93T3C4Jd4mvxdvl' +
            'h24kochgZmJWDpD4SgXJNo7YVdCklniFStBCikcvsnM7OdZtU7QifSvckce5N81sAphrIJj9pYrp' +
            'Ehgq5r6pIKsh9/PxEwZKGEexJFTNh4hEohirc3oYyYLrfqpUsqT4dbIIDkI6Y0J1d8y57688Q1bq' +
            'kBdFPD/XU5UEbcthM/Fr5NDN/NoT9SoldHG8dKKe3WO4EPnPF26C6I51Eah8Xpe8GUJr+3X6p5uF' +
            'JkypPed21G5ja1wimHAMxrpc6M4uzTuwLOSr05O+a4EsAshnfjlv2tnOq9qWeYeWSHsnLC4RTy2A' +
            'zx8UgiP9t1wMc3kf1XTXKcNf6svAnAxCCkf7Nh5PQG9y0eYJbbwxAT0ku5hQx+MJ0YFd2Nfh2JzL' +
            'tXI2r8ORebuEzklMd9fFpH9541nTCmVuZHN0cmVhbQplbmRvYmoKNSAwIG9iago8PC9Db250ZW50' +
            'cyA2IDAgUi9NZWRpYUJveFswIDAgMjg5LjEzIDM2Mi44M10vUGFyZW50IDIgMCBSL1Jlc291cmNl' +
            'czw8L0ZvbnQ8PC9GMSA3IDAgUi9GMiA0IDAgUj4+L1hPYmplY3Q8PC9GbTEgOCAwIFIvSW0xIDkg' +
            'MCBSPj4+Pi9UcmltQm94WzAgMCAyODkuMTMgMzYyLjgzXS9UeXBlL1BhZ2U+PgplbmRvYmoKMSAw' +
            'IG9iago8PC9QYWdlcyAyIDAgUi9UeXBlL0NhdGFsb2c+PgplbmRvYmoKMyAwIG9iago8PC9DcmVh' +
            'dGlvbkRhdGUoRDoyMDIzMDEyNTA4MjU0OFopL01vZERhdGUoRDoyMDIzMDEyNTA4MjU0OFopL1By' +
            'b2R1Y2VyKGlUZXh0riBDb3JlIDcuMi4wIFwoQUdQTCB2ZXJzaW9uXCkgqTIwMDAtMjAyMSBpVGV4' +
            'dCBHcm91cCBOVik+PgplbmRvYmoKMTAgMCBvYmoKPDwvQXNjZW50IDgwMC9DSURTZXQgMTIgMCBS' +
            'L0NhcEhlaWdodCA3MDAvRGVzY2VudCAtMjAwL0ZsYWdzIDMyL0ZvbnRCQm94Wy0xMTY2IC00Njkg' +
            'MTUxOCAxMDUwXS9Gb250RmlsZTIgMTEgMCBSL0ZvbnROYW1lL0VMT1JaUytGcmVlU2Fucy9JdGFs' +
            'aWNBbmdsZSAwL1N0ZW1WIDgwL1N0eWxlPDwvUGFub3NlPDAwMDAwMjBiMDUwNDAyMDIwMjAyMDIw' +
            'ND4+Pi9UeXBlL0ZvbnREZXNjcmlwdG9yPj4KZW5kb2JqCjExIDAgb2JqCjw8L0ZpbHRlci9GbGF0' +
            'ZURlY29kZS9MZW5ndGggMTU3NzUvTGVuZ3RoMSA1MDI4ND4+c3RyZWFtCnic7Z13fFTF+++fmbOb' +
            'sJtsSCcQyLYklCSUhFADJJRQQiDSTOi9dxARQRDFgqio2Bs2wIaxo2BDBBQFBMTCFxBpIQvSQl2y' +
            'cz8z52wIEdTv797XvfeP5cV7nzlzpj7PM+Vk5yTEiCiEFpBGjUfMmunQmvG1iFkHQkdPHTOp+geN' +
            'ViK8mYiPGjPxttGnXnrzVyKtMZHFMXbUsJFny7w9kbQAaZqNRYT5tdjHcX0frhPHTpo5u3qK80tc' +
            'v0XU69WJU0YMo09HxBENQfpeqyYNmz01NpNnEr17EekdU6ePmjrwkckjiN5DGuo1YtKwqStKzh/C' +
            '9USiiBU9ezdKrz/j82yiDdG43w9tCuW/Ui8aRIOKKbWYovKKGxQUFnebVVRM7nZxxUEphW2KVNy8' +
            'IseuYhbVMC6tmKU6fisOTUkr5ql5vQo7uYucacVa6rg4R3F2QaGzOLsordiUKrM63c45hXvjfyiK' +
            'R7rC8vgTRfFuZ7E5pbA4d1aRulFUhPLMqbaB/dOKg1LfdbH7ULvjvoED44sJxQSnvpuoorIroqql' +
            'RkY4WjZKK7akOubJSjagGEexltTV7Sg2JXcrpoLCxaMWD3PIQIt4p7MofrG66qVfyQqteuvC48Od' +
            'KDEk1bFDdSc01dGoODhlYKHD0dmdO2y8o9AxcrhehExnkzWjasdiR+fFucPcix2L3ao6tyy8OBsp' +
            '0T8ZUZw9Sl4gT5iqqc3uOKcz3rF7MdSATF3Rmr5G25wqWfVUt2O3UbnbUZjXO95ZzIoKF6NDXd2L' +
            '3Y7FXRe7h8kMehYp0orDpRki0e4I2QEZiKzSgcVSuIeNH1q5JzJrVCo6sfheqbZuI92Lg4sdBYVZ' +
            '8V/iTnTq+5TNstu3Z3lrwmkEqU+ZuG+h/OxV6B6O1rvbx0Mwd3toPrtX4XvkoA4j2r/HHAyi2DGi' +
            'uOao2v66YlKLEQu94CMNTkecCvExEn6nUTBRRoQzIskZ4Szkob7ObLTvGf5red0uvCsxShfneSz7' +
            'DaOLWIw7xp3pzszIzIjhsdtyt23LZSHyc9s2vcwUcYx5+TdkoxiiqKZttYz0iOggtyuZHBHhGenN' +
            'MlMSGma3dpbcOm36LDbLd2hJt1x2c9F9+Y3DfUve+WQt2+nb7/vP0idRFqPR+BiAsqpBujPbsuYZ' +
            'EW6mPT+6bY1WhexSO1vDXuWtZbqGqLga0lll+4J4sLtZZHNnJq82+4E6g+vNne+7k3/Tbblv2xvv' +
            'MOuHN6O3SeIYZ0gfRQlUD3liY6KDXMmZTZs3ZJlNm6XLy2RXUEx0rGxv0yBXkBFi985ZtGPRbc0a' +
            '3Lru1gYzpnbo0KJ5x5Z397opp0NvdkurW4fNuX3YrFau7Ca9x4/vnZ59oE1Gepus9KbH8+f2yG/X' +
            'FrqJQDsfhL6DZUuTnMFulsHcIZz95juaP4KZZjMaO2rq7D17pOZZfdbd94Gu0yJ8PKvyhSs7pceG' +
            'B7nrqiYlp7AiVvOBF15cvO6tiVOnTnyL/7re99bXvZYufmCp0mF/Od8hL2wXFeOMgYHlZ8zHbHX5' +
            'OXbJN5I9yLpf7sV/7XWsV0X6DkhvQfoItz/1IHbMN5MNlE3yJ0Xa3kh7t142cyKxdCGYiNf13T9o' +
            'ELsVqPS+b1jr8rpIPxK51it/U2WvHyw7imtZVneUdY9eL4OVZWksgt8zzndv4Sg2TyXsWf4u5Fu8' +
            'j9RJMmx4hB+GJjGDMuVh4c0y0mOTXEHhsUoz/MiXy19Yv/755V/5Xpz50MMlDz/Ehr28eyfrt3PX' +
            'wtd8Z1579e7FK3T9DsDHONRtpUhVVoqsHlo2Q8VSw3zctAGHB7G0ibf4eq7vkJfXYT3XBk3zbeG/' +
            'TjnYcXZH1X54O79J2Ui2P8Kd6Yxhwwed4ln83vLb+L29eiFNLNabl5AmlMjpDmFuLSOeyf+8ZPSq' +
            'V0avHXv/yyNX3DOW31z+OvpZzAsksmwbyn4c+arpZas87K5BvqMzdm+fwhJ8f7AEttb3PBuBvjSA' +
            'XmrweKpPTaFlqZGYiOiM9OYxUkN15Udm07bBzduyNqxpstsVFByV3qwNC9OiY3OCvh82Ms1iccfW' +
            'q2/uM7jnIEtI7ai0uKzaiU2S27RolWXu3amw5qhuWc3YtDe65vq+r8/bWZLq5ffpXCO5Ts3w6sFW' +
            'kzmoVq3Y5HppjX1fdW0wODQ8NK0gVeq3GdoUgvaHUU20KSNCtUqarG6MO6pidCU3691y3NjZc8dO' +
            'aJ13uH1BQfuOfXvDeY73WzZ/4fP9O7AfpqyZMqVo8FTd9+yYZ/ain3FybmjI3MZ4bZ4RxlQfZR3s' +
            '5z7Vspt2zO/RaUJMn2pTB0+YN3/8gElsYPPWU4YPGn/H0AmPz1/43HDdB2qhvJNoY3WKV1rOvFpO' +
            'jQjt6myQzE52c/VsNn7O7aMnZj7WsU+fTmiqdM9OTVKeXjTvyZtYdV/Z1AEDp0weMHgKyq2n5pp4' +
            'eGkdOeZja1xtpPLXGrFmpywWHeDMdweLT+k92t0nfFb/yQvumtRtWs0Y3wKWzPq0adertEu9juP6' +
            'DX2c8We7ZTdP5aacopt1XUiv5fw/aiTEuJX3Zegtj0G5dRjjN/fOzc1pVSMuytqKh3b0tWCbOxa1' +
            'aGfuxDJ7oY11RDI7hjbWlrNhDX+vMzMiosO49JoM2XU4Caush3MD594+cnjb/MjGQ7oOnBzcN2xa' +
            'n7buPGeHHj06tu+eV+PJeQteGNDd1y1vVL8GfboVDhkWn57KDk8ePGTShMHDJ+ntzsXHEeg8ClJp' +
            'IEZNIm2Z8lo3e6xD/ewevXsn5bXoXtSbTWjeeFiBbz9cwtO4bn5730xlt/b4fMK/hslZpTnWpyd6' +
            '9+7DQ8vLeOgP48bpdclR+tTVueepPpXmHrSDX0b/ndI7Y2T1NfxtiKholz+Qm+/KazosNalL0649' +
            '+2Q0zOiif/DQbo0aFKQm5nX23crGpTcvaOn72C/9fT2KOqIq6oi9tlT3Ta269+/dKj27B8oqbN64' +
            'Rw5m3AmNWsg+o5+J8E8f8lvlTMOM8QMXqnF1/LDwafPmT546744puQUFuZ1u6snjH7/vzmWPs2qP' +
            '50/6fNKkgcMm67rohI8clIV5BUZVStd7zXL69OmTn9ihXkgM+5p3G+M7xUOHtM7QkMeF+rcgTyJR' +
            '8wSmV9iIGQtmDXeyPgDtmIn0kT0nKLNT8w7JKT0GdZ380XBWqI3OyGqYUdAj95YRW4Kea9Q8LamO' +
            'yxoV26Ft15v75PdJSaztDo2K6gQVvK+3MUwcIx9/Tu0i4NNqbKs5LDNC3334+kXF16xet06Tpp07' +
            '95ZO/XTtKFNucEo9tqTjUn3ty0Gb/+ChUudO/4CGf+n6wvryR15SQavuA6D0nB69uzZN7ZHDlvke' +
            'lCpn9WV+UBj+/q71ZUOqZ53jIVqJbNrmtcVWv/RO96WY/zTVwmU10nOoT63Et4v6m/d6p5e3Mv9p' +
            'xFf8i36dr5N7L3hdodx9KOZi9m7KUykMOLXbqA5/FjP4F9SY5VNXkMwWUT3ehdKR9mZcN1QyVlxE' +
            '+hQwGriAA9QGbiO+IUgCyUg/WYIy0mQ5ilTK1y4g37MUAXryHdQYFCHcn4+g/pqVUnHdG/lGsjIj' +
            'TSoVaDmUh/juuJ+MuAFK7qBBCDdGvhiE+yKcoBVTLKTEhvjaKCdbtpnFUCz7CWWnilL0JRZlNgDN' +
            'UIcdshaoh7SRkHVALu3DON8n/sT9Vgh3RP25Mh4kynwyD8rphPsu5JM6zEHYinYEyXaDaFk260Ep' +
            'zIS+9EC5XSjP0P0cpG9q1NsBhMg0Un8osyY/IM6y6ZTEvlR6qyd1r+LyoefB9KSyyWCKAuGIGyjr' +
            '5jVhN91OdRHfiU1Cvi+poTaK2iimqLqGGnr/C/C0EGULaYdKGO3tDB0KSAvSRPvtUBW0awhkgrJF' +
            'ZaQtnqEBsEcHQ+9/QVtADQxb1KsMeeG0XuwtvOISOGXo32+Ha5H+NULZMKcy0hY8Rdk6WvVX1nmt' +
            'TJF9V/XfWBaBWqr/0m5SP7KN/yCVP8OnbiSlr6v+7KC6kMHQ83n08wB0zSHP4boc8iiuayl/jKUh' +
            '0Ecffgg+tYDaS19D/O9ynEhflRj+my3HjfRjKdkU6qhkmZKEeJJ2NOq+Vn4Of9tIE2VY2RW6/Yss' +
            'oRTtDegcY1COgyqyiRyXcmzcUGLMqnEj5VpD6v7VV9ntX0o13jHmpI8Z9tXHvbRZFWmM71paP/j5' +
            'c1SgxvEP2Mj0AdL3BWinbB2t3aXGQk+Vpqmac/ojvpEx33A5LjQXbIj6MHfm4ro9K1Lt0O0gw40x' +
            'H+XADjtEmV+XWjTKyoT+itX8lah1Q3myDjk+ruqmNstXtpZ6Ib+etGro81T02Qqf1ceWFXmjK/XT' +
            'IUE4VJWjz8/Zap6Tc9B0zDH6fD7XbKci0xrgoFqgAGUWsHXU0XQPxnaxGt+5/jGC9Bp88KTf9v/a' +
            'Rvo4uGa8yXlGjvW/jANDb1X9TPUpDPvMfWK/ORPt3ai3uSLfLOjN77d/rSNBzQd6fFiltsixGeEf' +
            'oxhjt6N/c/1jzag7qFJ/4dPiE8O30/T+ibMV/azq0xbY4H5I/9j22+fa+uvdcGz56zV8Wo57lS8d' +
            '805rtdaodQuE8KGI66+vX6rMRPRHrklnkf8IpI+cDM8C8PE6xtpmV+tqKoUa86iCheI5RMCHY7Fu' +
            '/QreBCbMFeP1tc8P76XKyuXN9TkYbZX6iee/YX+QD7+TzFSyk2Ih9WEz0GYXfNyl2u1iKSi7Acik' +
            'BLaNqqPOOKW3PmA69Biv5jX/WirnWwfGjJ1dgQ7hC7yeWjsbVYCxK3XGLqNN1ZB/CtI1RJ9+QnnJ' +
            'iF+NeF1HKr32FvxnHShG3LtIo0GPVyhMi4SvLEOf+4JISmNH4D+tUN+taGs+bApoJZ6lj1MySGDR' +
            '2AOMUfqOYd2w5sdSE7YRqH2SQT49DnqCOIPaBhkGsuwosNCIHyj3Jywc4zWf6oDewA3GGMwBt4OQ' +
            'KlQHM0Ab0BKY4bN7IQk+sFTep08xL+VTPIjAfiQOuqz3F4KpiwRpahjtaWK0U9q3lsrfGeWY0cYP' +
            'FZGIs8h9Hm3Gs/FmrFO6jKvUNvzzfUskqkNuAmvANtAGrEd8MuT34BA4DT4AGxHfBPL41XQqLTbK' +
            'Ih1gFRMperk+H8BeWWDfKzLBrcBhlOcHO1/RF7yN8BnwGCgGZ8FSo55yo11f6vUrjHp98/R05St1' +
            'fG3BKIRbgg46giPuCbAMLAQ7EYdnvPJVlfq/Sm+/7wXwhVHfEkMnsl0Pg7HgEeT7XS9L6W8t8rWC' +
            'fAncBCaAuQDP4KI15GcAj1vlsg/vGDqUZa4zeN2I22WEnzD0IvWwGnwIXgWf6OX4/gA/GH15Qfo2' +
            'bYK9u9N8ta/XfU2ud2YWRf20SPGLliV+YdMgc0Splg9pxXWCKK3Y6+dSL4zTTDX/zcReFvOjGrfY' +
            '66v7ch9q7PMxr+cYe/wCud9H+npqny/X9x/UehHLj1FTpGmK/NVUfB+speHYRyXC9zKoBa+F/aCM' +
            'S4CMwr66KeYqwv54E8pFGm7D2E2gFhgfWbwuVee1KUvOO2w3hWOuSuQTMP5bIq8bc8pEzFvHMRfI' +
            'Mg9jf9Qa9T2BOfkQJaKPv6l4mUdKxPGOmO+OoH35mMcmYr46TC1VfCraKn9E1Yxaqr53UfuMAv4I' +
            '8EEnuZD6PryxegbC2ivna1ML6Oo81hOZZibS/AZGqTmyN/YO1dV+RoL8mlz3UZ52P+7L/cpvRvrZ' +
            '4GU86/WA/BH3a6MfkPwho06pX5SpDUL4EZR5BPHTqYXWFml7g67YF41H3AvgB6yvxyBXI1096DNZ' +
            'n3/ZMjXXJkBnyfwsfEOuQ8319YIdgzTj3nhIzM8yD0+DzFHzdjL2H4lsF5m1YQjvIDNvjzxn0JYP' +
            'cH8zeAp534O0qPSJ/AKkHfN3EsqR5GAukvUHI/95SqTfsQ/GMwPtF39qaWTX+qq6IlU7ZHtQl2yH' +
            'thr9/hA2vww/gE01B+pE2/zxfon0GGu+u/X5RgQDG8bbzyCc6Eo590IfnVH2u9B7GOy8BNdZuC7C' +
            '3upBSPgCuw/3euJ6D+p9EbpuizY8jj3WCdjsUcT7kO4V5AuGfAtpOfTRGX73IDiE+FbItwfyO8o1' +
            'uWCTerhugPYuUmOlMTdByn3Io8onrNChWcnu4CnYowTlrcK9leAOpLeAWfD7M0oWQMp2NeJrsbYb' +
            'knyGL51VZRVgDOXyNViTQzEGpf9IW5ZAtoY0ysIzZwHWzVyZV/mn9BFDqv3ZFN1HlZ/IfbUd5Rmy' +
            'oi45Bs4ae8DaGP/Sh6UvGVL5r7ST316GlL6p/AO+rGxcVcKnVX8xVtgDKEf69Htq/9iYedCupzF/' +
            'lFOsmn/aQQ8rMH9tRr4ZSC99Z7vqfy7/E/7yE1iL8Ensqz+H/ALlxUIuxb7wE/jYPbjGfkmrQW7+' +
            'KeIxhnAvnT+A+4+iTxeQvzelaSb0eQCukZ/fh2e2T3G/BHvNP/Qy+UFcL8P1hwhPgY7vRJnRuJ6N' +
            'Z4xgyO/Uzwl64rkuE2tvgrHOxwKblJhXczDH5cIf3ZjTcjBX5fBO2FcMQ1xdhFtAtsQ9+BP2Nbla' +
            'PK5lm+tD1gSEcAukq4d9dxTl0CVxnFdH2scRj/zop1vWAb0l8xCkc4IumMOnqDwSN8NY12Yi3B7z' +
            'n/x50XOwk0M9O/WX+0bsVCxY6EYD+WPDBcb1ZoB1jOTXfTtANsAYxOgmOgx/xt6BbqNdhPWYz0c4' +
            'V+1FiC3mC/As3BN7lR2YN/qhXZOpnUzHhmCNmELtsHdug9JbYazK+aslL6QkFT+JGqt0cyiDD6E2' +
            'PA++1A73W+Bebcz7PRA/mNrCd5PwTJbF30HfViH9c7DLUmqB1qayQmqO8lrQt9QUpIMMkIq5fHwF' +
            '07E3nk4387bYh0oW0X1Sqh/pbUCZG1BnW7GGL9KBbidI+Bs0CX40EnPdu3wG7m3VYYcg3xDvod5h' +
            'fJkMI20toO7TSiXbGtxB83lXvUzkkWnxpElbjR9Cyp8QnANY/+lgpfB/APZBhP0Dw/6KYQ6kN0G5' +
            'HmbVDRms207dX2nwBlhlhH8y9iFAtGVNoNfPYSOs61oW1rvtyAkwPgnPM6Q9jfCdiHv3WrRCzBWt' +
            'iWudKBThBH4CcfAibgU9wGIwUX5jCLDTwjpCHC2AHQk+TPLZGvoh+AFhb0AYX/JnUMRvwjhsoadj' +
            '+yH3QmJ3CL8N4kHKd4m9r4OxTJi/FSrNPUaeZ+U3DehpkO8Z9inVoJ1iP2FHRQcEWuiT+78NYLvB' +
            'Luoj94pqP9ed/hBrkK4G5ECQAR0NBjOwDsRA3mvsC6WN7pN5r+n3F5X6tVdvqyb7Px1Mo9lgFn+Z' +
            'zcA+4E/4dH8wDRSCkaAHGGXgAgvBnWwSfPUuuhP2SdAa6mUq/ci6ZN4Ret/lHh6eE83kM9hSYlob' +
            'YswrzkC38vso4o3Uz58j2QGaif2RG/OpG+OpBublGljXGNuJ540DlMI+QvggnimeQrnwLC6/jc5A' +
            'eRqePx4RP8LvCflI3f8evmMX+9lePP+8LI7BL9IYdsJYNyx4VmVYd0mekmHfISz95hlwBe2BHVW6' +
            'K6oMJtd1JmeZr8S7hHj6wCefIcwA842Ixf2PWV2U0UjIZ4JmoBviG7GRFEJ7fMd5faM9H6O+Xnie' +
            'Qx+R5iRstQ0+lYPnpHz4RRM8V0aw03g+K8Nz1R9UjV2godgTJSJ9bXabOKp4G3P3fOGFrMX2wRed' +
            'ZKMX8Dw2CXnjoJ9R8jsluacXt2Iua6wNFJdM2eKSNkr8ri0X5/lOcUnxtDivFUF+j3v9Id8QF/kc' +
            'cZavQbgE3C8u8JfFZb4U8Q8i3y2Im4/rOyEfwfViFX+BP4DrBYifA55A3CzcmybKMCddwP2LfCrk' +
            'KPAo0u1DmongVaTZJjx8OuKeMRgtzqPNg7BfPsvao39pwgX9XNbxwXvLMXJ88nlpm/FMsprPRXsv' +
            'o7wlKO9B1dbLfDk5sU+wYz6PUWRjTc1XvhKOOTQMYzGMP0xhyP8jeA51n+e7oaOv5BrjK6VY31NU' +
            'Q2TByp9owWKbtlNshs10n5bffO8Sx7XVYhv2NYT7RyrYKX4Cu6Xkw1HmegrlU8Q5hC/wIlyjf3wh' +
            'rt8Sp6CrMn63KEObGK8jfDweyDH6CPrjFlf4WHGR/Ukc+cowh5/DPQ69XeDvi5P8HXFK7VN6iEvK' +
            '/1tDd++I0zxMlCPNed4O+aVMEl7K9G1gL8I/TlMWnu9j6Fc8Fzt8j1IMnl2TfXdRvG8LpfmmU33f' +
            'TGro60nbxBD6HM/QH4lqFC4c2nqxVfsQfR2mxi+eZ32j4acc+2fGDmEu/hmcQ/vkzL6VNNkHtpGC' +
            '2En06xTFY23MwhybxRdSltYIslDtZ7I0O5iHfdVkXPdF+E3I/mAA9pKxiJf5pmA+QTq5P9biILG/' +
            '1npC3oz0qSptFva9CVw+r5xBuI+6LsDeSYYLtNmQN2HN/QD7HQ/ShQMZ/kIHz0kJfB/CX4HPUFee' +
            'EQZY7/QwZlIV3oW4jWAKrj8x8n9ulLUbfV6D69lGnt0IxxnlYP5nv0HOkjsOxL0CVoAPjPZoaN9X' +
            'mFdX4Lm3DAzEs7Hc039LdbCjyeS3qeeNRJSRieeGOL5clLLPMW7mUSb2FhYmsC/YKQ6irEzsZTK1' +
            'zqJc+xq+Mgb7kAzsI9EG5M+Er9bWpgqfJvvwCq6ro6y9WBdD8KzsxvxahnTtxRE+EPdmY5wMotqm' +
            'eNx7hOK0bth7Hqdw0ypxUYVnY7/zHKVry7HeTQcPUyb8IQh73jjYORNzZ4a2Bn48GfvyjWiLBeWm' +
            'Yr5dqsdp0zCvXxRezPvp2KdnYu8s1/YILRfPRONUP+1cIPwLwu+BulRNG4D2SRvdjbkKbdaS0IZJ' +
            'qr2Jqk0PYg9+QJTAV9K1RciPNmlvI1wJvvvGVE1bwfRrUWmvE4exms4GgC9AV4MNBtHga7ANOLHX' +
            '+wVy6VVMjxh1NQBlf23D/6Td/nZWbm/lONXme9CWFyG74/pIFUpujPYoWGrw6FWp7i27KiuHlXwM' +
            'de2FvPlaeMF1GA6+NcJDwVZwxWBrJSnxgv2GrHx/nx7HxunwDZV44F/WO9Qo11spLOUwIzyj0n1/' +
            '3LQq9f6begoqlVNQSfrDw69z32gP62/4mJR5iEsHm/8ZbSTI0lHXWVfv4ZlI990d/31ZFeGR15Z7' +
            'vbpUPXLPPBXyIuJCDWkxZDUwtVJ4IpD+9JgRftWQ/vh5Rpz/vpRzdckywSRDfgdaG2DcamcAfEYb' +
            'a9C2Ev2qcAyUXkce+Xuwh0jnpusQbbTRH8aYxB7mxvKd68QX65LNBJfAdvB9lX5UAvPx9XnfsAvG' +
            'JRuv615rUoUWVdgFUBf7kf46j9wAbSGAH2O//Zc5R2t5nTjHjWEn9DGh+juhEvAhLf7qNZ7z/jIO' +
            'tbBrMTmuovT8VaXrUD0NnuGupcpYkD6tma6PGk933BiGNjLZZ60KVeePhCo0qcKsa7nRWvKv43/7' +
            'h/gb+Nl/i1wP+Y7/Q1gr6avqnHWDPBXj48sq3HuV646nv7mn+vXjtVTkq8owg3urcNDgzLVUlHP2' +
            'Wm7Yjjd1/skOFWurwY3i8Tz03+e5ke6boW3T9bEqx5s5Ebhwjb2T9pMeNsu1Te49rTr8Ux3/tX9P' +
            'dY0vV9rzaJGkzynSJ64oWeeasXtRp0IXmNsr5ulUY76be1WqtazFVakdAht0KtqwWteTWk+NPYFa' +
            'q+XaJ/ss57l2OrRf3x9qv6j6nKrOxaC/Liv2Yef1Pmj1SJ+DZhn3/bpcbPij3GvGAZTNRiDu6hkD' +
            '/exKVVn5PFOqOs/09/JfnnOSZ/fk+ZrrnGuqIvEcmyr2+6/Vead9YhvymsmLZ2HjHMhfpH6WyZDi' +
            'cBW5T35vaJxRuEbe8IyTIf/FGYwBhv4GGPqrfM6p9bUSzyv/dO7peuefrif/7RmbZ/GsWaa+51PS' +
            'fx7qn6T8/tQ4X+mX+vmpG5yd0m2lzowFGefpGqjzVNc/Tyclwc6b/ub+v5X/5H/BqGfDje6jjb3J' +
            'Sz3Uubl9+neuN7a3WHnD+/5zW/8g/3I+zX9m6x9k5fNr15Xye+y/Q/+OPYwfEWd4GZ7DPxAn+Vpx' +
            'gr+E8fYsxglR3evyG9J+J/7Ec/cpbbo4rY0QJ7UpyCO/H/8bNBPSWsUF7V1xRntfXNTeEWXae6Cv' +
            '2CthCZSqvltPEGXgAvCCS2CLor04zXLEOfaHOMMOI7wXHBJn2WLxO7tH7FPfpV8HLRjtC0c9+1Dv' +
            'HnFWuxXtuBN9kN+7/x0e9PEx5N2CvEOgG/ld/N+gMZQdhLK/B98pnZzVnoBchD4vQn1+vfv1aOgF' +
            'fSbZ74o2++v3l/0PdsSaFIFnpzBtGfq3DHX2RZ0DxQmtA9rRGnb8J7ssR7pXxAVTgThj6isumvJE' +
            'makH+nwadikTe/+x3ytQ5wpx2jQejBUnTTHirCkTMhll1q/U7xv7IEA9z5JZy6YIzI0zabM6SzTT' +
            '+C7Sdt1250Cv1cRBzE/h2gLMUxOoN9b5XqC9ypcgfgB7wCFwCmxSMlaUY2xb2Z3iMJst/kD6juAm' +
            'VU9VH2hpIMNcrZU2dX6zifgNuv2WH4b/3U8uRT45rqufHPGFOt9SIDZpDZHvTWqKtL3ALPndkTyx' +
            'XyHluafL+jde6jujWOPbzJF03X/GGauGmIe8Eq0EOgGsBeXxZmIC5q8c2kvZfom0jY3zWY3UmdtU' +
            'NVcls8HqfLicr2/mz9AMtGWmDF+/VqNuvc0Wc4E6y9WE/YTyVqmzbFfDs8mC/jSR8Mk0HHXNBfny' +
            'TD1/FGsgYB+RW+sCeyylTFoperAedBuwmwopX2uvkHkayvPqwA4c8j0D1NNO5ZfvHMxR53CYvNai' +
            'oHeNsrSbUecO/ft2+h1ShgfqYcWN+jWYatESrFWDKRpEgjgQa1ADRIAQgymgBxtLaTKfOkfvP2f/' +
            '9/lDDWT+7mwC1szJYCzud1Ll1uJjYJsidT5X7o9qqb3JG9TZnEQDTO/RIG0K9nKj0Kda2GM8rPYd' +
            'ceo8TivsFd7C/PKDOo8fofYhC7BvNJGDqPySjmgG6iD8oMEq48zZrWC2QX3EvQPSQRPQ1AgjjXe6' +
            'fn7NtwUU6Gl9jYmutEf8anDFqOtjo9xd2miqrw2g+urs5SVKQJ8ytNoIZ+tnlxCfoj1J9bRv0dYx' +
            'aPe96r2Q2jyL+mn1sY8bTNW1u6k+OwAf8JBZvVOwAnaeTtV4ITX1v+Oh9RI+vpai5P4KvjNISlMU' +
            'uUwnKAr+Wl3ue+QeRZ4DU+eiCfZIoPCK82RL1HnQCLUX+Al1pVOaNh/t7k71TS2wT5VnBAqunhGA' +
            'H3bQRlKiuRX6IM9/5VIveQbN2NcWKOS8YaJ42CnBVEyJ7H3UP4o6gWhDRoHwSteRhgw3wrHyWp17' +
            'S6WR6NdI7V11Bi4BMsG0iRLMe1VYxsVCxiIuVtVtvC8j97fybD9bR+0xxtsjzn9mVu4BraaHVFi9' +
            'HwAZgbgI+R6L/30XtUfeA38cAH3swdiCNEVSnCmSmTUH2u1AH/xyD+y6B33cQ2kYk9VlPgmbi/X9' +
            'fox3/TpNXd+u3wMJKLOuyjOAUlF2vLw2dUSd/ncusEfTmqNfm9BWSRdqbpBWEf4W7WtO4xSJsFsX' +
            '/Z0kdY7dJ66w+9T1ILCSJ2Av+C3G2rdUUyN1DjWPObAvxvzJ+qj2yDYk4F49idJ9bbBO2WGINoRe' +
            'ke/oKNpAv2WUhHAGaGDUW1G3QVdFA5R7Nc6fTvYhTVurY6RJq0JtA//1NXkr6cNPLdDML1Uf5mKs' +
            'zIVfzIUP6HSS4F5KVWC77sAubagoxPVQMJfaXkMJdCW5Qm0k6hzzz5TNN+Kev41GfbBLXbaZhrNN' +
            '1AUMQbgrdCm/DxpZsSZ0pZqgOluAMXiVVLaABSl5NxVWojn4XUpZDvyvHcgw6AzaGDLTCO8Ea8Fe' +
            '8DU4Bj4DvxhxPUFRFdoZZdxkhDeDjmAA2G/kLwFbwR6ZB2vcBYydSIQnYK/v/leU6PsArYR9D179' +
            '52sl/eFK969J91/cr8pf0l8n7v81bK7Rh7k6f+nffxH/f6W9ZX+N0yZcvXe9+5X4m597V4ZPo98l' +
            'CI80uKzwlzMX/gb487RAgvBgCcIfgBe023F9O9bQq+nurJLuvmvSRatnWh0HxvgxrEOQ/x1sMfY+' +
            'Vfso4x+V9zR7pbQl9ERl5B72urow2q/AXuE6aaq243nwnMELxvVmg+e0lzCPyXdOsG/lvcmF53F3' +
            '1WvsrZvzFLBDh72IdfU27FEfpXQTnhW0GqjHwD9nqvc2h2KdGUstJHw7dalAnlP9xsAf1wfz+qeQ' +
            'R0BbXfrzskRcr0HaNdgf6vmb8l2QZchTiP3LcqzPs7F3kmfOQ/XymAlrK66xN07mK6gd1uZmRnnN' +
            '1f1QlLVAL1/GaRz1rEJ+3JNhVY+/fXVQdhY1YxtxT8pP1fshDdV5Vsmr2Es4DHqBl40zsmXqjOxV' +
            'autooTqmVjr+a5lHC4IsvBbtZx1+Qgf7tlxtDhhl1HPQSCPL6aJL9EUPb0J4K6Q8r7tfR9X1p55f' +
            'M+nIPnD5/tDLOqwEciDuNUN9bsjeOvxdyO6QGyAfuAofqaPqlGe3HUZfZJ+/BDtxfauO0lcTvT4V' +
            'Z/SHf2W0DZLHgBDw0dU2KuYibpMO9to6xQYyvBz3jhp9lWfMwyB7G+WvMuprhP75IAsQt64Suwxu' +
            '09Hked32CE8z2l1QSV/zdSr69IOOFgluN2zRFfXAB7Q43LMa3Iu4cXobpK/wN/U6tIX6fa2pgTzX' +
            'PtSor55hq7t13StSKwF7afsMXQ9VZ9BztYcg3zEoMaTs25FKsuRalO4NH5U6w/N+Lp9otOFRgyLD' +
            'z01G31GvBp/EXKbzgcFi+E10JT9ua9RpSKkX6V/KNySler+VzZIg8fzOd+soHUpbvGnoaZlhn0d1' +
            'fzRtQzgc4Y2Qu/XylN17QnK9D6ofL1ciwiDNYIsO/xHSCZlrtG+8HpZjoDJqrMbofq3ymP6KqleO' +
            '02TQEuEXSH93g1DGZMo1p+rpTB3Qx88QTgHVcH+0Uf49kOWQTyENGT4N3WmNIWVboWeS74W8ZvRz' +
            'gWG3MD1O6RjpTNI/kUe90xZN/Vg/Sqf1BuTbC+TzbQnyEd1OJL9/odb6KWh1EnqDbzAF+brLs7ms' +
            'PiVTqXgPz9sx1MN3D1svfyeRry64k6YKTk/Kd6rK5btkOaARwvdDjmO/ihPqnby6ZGXp4k8WJkpY' +
            'U8hQcZQ9KspYZ3GEvSL+5MkUxdLEYebEfvMR8QdziwO0jULx/BLCMvHM1ViU0DqxE2XlsZdUOX+y' +
            'B8RJtlkcY41EqWwXqyV+ojPyrKvYyv4QP7NWSHMrQFmo+7RKg3y02rePuUQkyxTFNFvkgiI6LQ7w' +
            'NeInPlecYfvV+T8T+x7tKxVneR1RxnuivbtR1i+4topf2SFxmnNxWJ3BPYm0F9CWA+jnAXGBh6A+' +
            'eQ53nrjE1olTuD7K5W/r+kWcZz+Li+wMdLJDeNhJcVy18xtxFvdOsLUo+ym0oQXSrlH8wJehLuiw' +
            'qmT7kbaV2Iu0e5WU+fxMR95DFMbludAUMkvQnxQJ5q4U9hbaE450eeKs9rE4A0q1WOFF247yY6jj' +
            'mDgDzvLOooQ/IjxalDhawR/o51PisBYmjkj4IHGMv4h2TiMTd1I0b0U1NI2c7GvxO/NAb7Fik9ZP' +
            '/KHdinQrxa+YE2wKIht7T5zHM3yqks/jWXwo2rme2sn3FaCvvRJ2Ds9r0DF3Iv/LkDLsEz/yn8SP' +
            'sM1OCa8h38nAfSDPQnNNbGEnxBbY7TA7rJ+N5v1BAdICtg39zNaRPsVrwpY1lZ0O8HhDTkb8JDAN' +
            '1xbhUXSEP3wmfuFjwR3iNLuEex6qyTMoXr2XDJv74WPEf2DnP3kX1DMBDEC7JNIPbsN1NXFOSVzz' +
            'YOi/IeQ23HsdfClKoLNjWiHC8G/+MPQGlK/rlPC7ED8EY2mzkb4W0gPUt5Odhu7eFTsU42FngLjT' +
            'fCPCo+DfCGOtrimBffejjJ8wX5FWA/aqDt+Cf/LHDBkktvLeoAN8/2OU21OcU7qAZEfE7/wt1Bsu' +
            'tsJ/tvK7Ub+kEcJdIMeKn9HOn5VsjL5egO2SxMEKaYOPRWK8YwxA56fVWLiM9mNcaEvFz9oSHf4d' +
            '2i55HuHHjDEjx84alGmBjZ5CGxpifOJay0UcxoPyd/i59FVWjrxy/M4Tm9TYXV/p7PyD0OVeSlM+' +
            'Isct7Kvs96UxZqV+r0DP0DHbDvufQT45fo028P/o9co5g08FJC7xJzHmpoGnMN5mUopmQVk/gM8w' +
            'XzwDnsBYmQ6ChZdvgI/cK04iTs8jfa8SWjvo+gJ4AW2aBqScDe4Vl2H/y7DLUfTlKP8avAKewFia' +
            'Is5rp6CTH2CDboirhfbB5soH3oJN7wRvg7vFCYz9rdrj+nzJE9EnKTXwDvp2jzhuyhA/m6qDBsCE' +
            '+LcR/wB0/wn0LnUv668JOoME8DTKnQmkDeR7DX47qPcartqCZ8BW8r0G2IQtg99Ju2DuusY2Fe81' +
            'GDbpor8noOwi7bES9roHcX6byLHj94sQZftjqNvjf7+AnvbdjDWpNhhmUFPqWH/n2HfCeDdnspbu' +
            'k+9FBIFcrGNbsZ58CzudoFdFFJ5viAn0+3748P3opxnzodTZE3q9TK4/GCfIO4KeFY/TNPE+ixUn' +
            '6ReMO0h11j4CY+0uHaZ+maNvLu0UfdVaqxB15Ts08t0fhXy/ZRjm8xchXwID5Ts9wof9XiS/BazG' +
            'tXxvaIv4hu1AuWaMK3me+zewARzGdTvIQajvIGQdSPkeiXx/ZSGukV/mY9+Cz3FdV707VB/PAvLd' +
            'n7rYtxLrAVYhDvWzMYhrCwnoItYumRcbFTxr1Wd2yA56efK3wrLXIGN1VJrnZR7IQ+r9fJmH1Fn0' +
            'dKyhl4zwcKPts8FTYLzBy/r7POxtyJmQsn3dhFA6utu4bmBgNvL0NcBOh/+insnN7DfxoRaEdsvf' +
            'MvUHhajz2w8gvFNk0k7fINotutEu34SK653ikh+2HH38VNcTuwXsw3PyNiHY+1RN2gn2awP7OWRf' +
            'pB1J8znpgDho5D8LTtFOVVcQCFO2D6qgewXSH3aKVBlm78g30ERHPsB4t8vwIfW+U5z+HZbS1yVd' +
            'p8rWc3R78xm6faUtMC9d1Y3USah650t/z8hv7zrEZRplh9ZYoy8Z/rISY2qBtI3w4bmEtCgg34k6' +
            'B5KJs68whocb74fJd9A6gZa6ZFNQpryO1P1F9kH6t2r3dfoifUOm8dej8lYub4fhXxmYj8vEZTyf' +
            'm+T7R2w9fKETyh+AfRb2aRhbnM2nIPYBMcxX5ewH4WPDqRr6lMxjxEWsP5dZjtyHIN1K+Y4Hrqcj' +
            '/SfwkedQ5gaUxxD3C9a+jSj/HewLj4kr2FfIdfEy9jfn2DqUDftjXsf4R/gLpPsV9cj5PBRrQRTS' +
            'dcF+5xbM83mYr1ur7zihQ6zZD4p9fJa4qKViDSrDvLobfIQ5ohHGdkPUUxv7sEaQzUCYem8J+1Hi' +
            'WG+Pcvnd/1jsNf/EPL9M7IE+zWwRfHCAKOU3oW9y3/k28tdAWxtg/aiJNi7E9WDkyVPvE53lO7AW' +
            'rUa6h7CmFyLPWKwdA3Bfcgvi0tHWLZhf5Hs52ONqNuz3YtG2Eqz7W5D3EPw6RTSg+r7u2kCxX8sQ' +
            'BxUIqzEv65Dv/9TR3wGiVF9nauXLosa+Jgj3oUTfNISHUkM8Z9T34enEN4Aa+QqpiW8FNfDlSbTD' +
            'YjsLojj2h/K9/913jy5c++4R7l/77pGJ98D+XOD+te8enePtoLOp2E8lYZ98CDbdIM6TxfcFGAb6' +
            'YO2T101ANmgLBoBXwPvq911YfO3BGPCUcd2L3URhdBz73sVoczz24h+KS9oHYAPqfh32OGm8q/YO' +
            '6n4E1/KdsoUI3ws7Po5+LzXeUZNx08HTSHO7ep+tTL2/NgWMBw8jzQHcnwRuMd5JG4M9Qn9xyWRF' +
            'fWOxx39Wf1dM8Yx+j2/FvUFI0wFz10TMXXpfhxv9HiKv5feX8I1I9j2e1X6ErywBi0A1itSOU44p' +
            'GkQCGyihHPneMWuCMbKUWvA8StLmUCutgJK1ser7iJZaL8SNQ7gO5Ovklt8tyXeNK6O+u/RT5T1n' +
            '+IqNoWXyHWcWRsHXvOM8iRpXvNvsf6/5Ou80y3egZbkqn0yzgLpod1OkKQzjeB/KH4Z5AHOsthFz' +
            'Ri0i0z70ZyBp2heYR64grhviGpJmwnypjcR4bQvSEH4F8iPIJfr7mPwPpF2AfJHwyU1Iz435exiu' +
            'a6mfbXM5V7NXKFWWo9JuQRnHkQ/rqHkaVTP1I4tpPdIeQ9xCLP01QE1M8bF6ehPWVRPWY60Uulyg' +
            '59W6Im0J5Hncfx/YVBpNOwxpVW1i/CLG+xTEnQbojikf8fPQNlkG1gSzG/mmksk8GQxBXYeF0PYI' +
            'gXJM2tO4ljaWeoJe1LunNTDWSjG+siiPPwS9XqSuLJma81PgO2rGl6rfk9IYc3xjnom4wRgXudD9' +
            'dtjhUfhFEWyWTOn8BGWyE8gvf0bZD9KNfPK7yEjsM09QD6wlLaCrxvJdLezFOvKj1MPUCNdLaTrS' +
            'yO8Su8HOTdCOybwZ5bDT8MPu1BD+0pM7kP8INWfbke5jyJOQr0AeU9/HNtfkd5BPIrwQcWXgF4TR' +
            'B7YA97IhbwF7EJeP6xzIXiAILEO8A2wAa3GNdrCvIIdDmqi5cWSj3v+QPtdhuXHi5nrI3dfUf8Gq' +
            'SsgVORpkG+A+RvpfWQdPqwa6V2FqJVYZ7Pp7TGMByjNjBjePBGh7EMoOwqgKwq426PhVghEfPBG8' +
            'BS5epVoqeA78Lv/2QIAAAQIECBAgQIAAAQIECBAgQIAAAQIECBAgQIAAAQIECBAgQIAAAQIECBAg' +
            'QIAAAQIECBAgQIAAAQIECBAgQIAAAQIECBAgQIAAAQIECBAgQIAAAQIECBAgwP/3MKLo19kaGkm3' +
            'UDXiuOYkf6834V81Mq1hYlExe5DyiqsVFL7L2ENF7+YGpRQ6i8OL8oqjeyGwoKhOcVDKwEIq1hyd' +
            'irWUjqzYpAeKzY5On5JpviCe8q6WOyulY1FxdIosmMxAA/IvkpiIgjrqFVZ/DrFMxWtkVfGmIPkb' +
            'pBciMpgW0h1sLTvH7TyDN9emaLdoc7Q7tMXaEu0lbav2s3ZaO2caZpphmm+6ZI4y2839zEPM95oX' +
            'mz8xbzCXmsuCbcGpwd0sLS09LH0t0y3zLXdZlliWWlZZii3vWT6xbLBstmy1/GzZazlouWzVrFZr' +
            'uLWetbE1w9rM2tKaZW1v7WLNt95kHWgdbL3Fepf1Qesj1lXWYuv71k+s31i/tf5g3W49aD1pPR3+' +
            'Zfi58EvhV6LKYufHnUt4NuGSPcZex97Jnm+/2V5kH2AfZJ9n/8C+wb7Tvsd+0l5m9zlGOqY5HnIs' +
            'c6x2fOhY4zjgOOW0OBOdGc4sZztnR2ees4dzvvNp5wrnG84PnV87v3f+5NzrIpfmsrlquGq5ElwO' +
            'V0NXU1dbV1dXvqvANdw1yjXBNcM1z3W/a4nraddK14eur10bXZtdB93kDnG73Q3cK9yrExMTxyXl' +
            'JU1MEsmpyWOSp9TNbmBqYEkblTalYY0VKSuXeM3eGt5m3ixvW2+Ot6O3pygXArZx0HL2ObvAE3lz' +
            'XqDNVDa4GzZ4SHtF+1E7pZWZyDTVNNe00BxurmVuYi4yDzPfby42rzVvN58KpuDqwY0tZMmyFFgK' +
            'LbdZ7rQssjxseczyBmzwkWWdZZNlC2zwH8t+yxErs5qt1a1R1gbWdGumtQVs0Nba2ZoHGxTBBqOt' +
            'd1oXWR+2PmZ9w/qe9UPrOusm6xbY4HfrEdhgefh22MAbtTyaxRUnUMJyO9nj7A57F3uBYYMh9gX2' +
            'j+wb7bvte+1n7Ocd5JjqmOlY6njJUQwbbHcccpIzxJnszHS2deY4uznznb2dS2GD12GDdbDBdmUD' +
            '7jK7qrtquurABm7YIMuVrWww1DXSNd41yTXHtQA2eNj1sus915eub2CD32GDam6Hu777WdiAEocm' +
            'UVJB0gLYYGjyONiAYIPG0gav0cr7vOSN8tbxtoANsr0dvLnSBuKgWC++FF+ItWKNWC6eE0+Jx8VS' +
            '8bB4SDwoHhAzxDQxRhSJm0RP0VJkCJdwCLtI8F3yXfSd8JWU7y3/T/mvVxKvuK44r9iv1LwSd6XG' +
            'lZgrUVcir0RcCbsSesV6pdoV8l7xer2XvGe9Z7x/eo97Pd5S7zFvifeI97D3gHe/9z/en7y7vD94' +
            '13u/8n7p/cL7ufcz7zrvp95PvGu8H3lXel/zvnru/Lmj5w6dO3g2+2zT0ybPZc95zynPn57jnlJP' +
            'ieeo54jnsOeQ5w/PAc/vnn2evZ49nt88v3q2er73bPF84fncs87zmucVzzLPY55HPY94lnoe9iz2' +
            '3O9Z5LnFM84zxjPIc7Onp6e7p5PH7XF5nB6Hx+6p46ntqeWJ8YR5bB6rp1rppdKLpWWlZ0tPlHpK' +
            'j5UeLd1f+lPpltLvSr8tfa/0idKHS28vnVUadEwcW31sRsnekl9LNpY8UzKmZPTRJw79fGjngbcP' +
            'vPp7+fiYsZ/E/Rr3fdymuI1x38RtiPs6bn10jD5XBf79P/0nf/c8WQqNq40k5yWiO0hfV5ZjzVgL' +
            'Odz4qw7nAO6xC0Rc/jWLjyAT5V8bQHg/ZHMddhKyAEVMQfgU5ExwCwgHcwwiwR0G8i8m3A3kXzaI' +
            '1n8LuCIePAReArXVbwknbStoDH4EP4OBQNZxGowA8q+Wo53aKLUkkmkYwmMgp4IZCH8LORfMR/gH' +
            'yIXgkl6eGe0zoy2mrpC1APpoyodsAvoh3BuyCAxB+DZIlG2+F+EFkPcDtN+0ErIYfILw65DQn3kD' +
            'wu9DbgelCH8GiTab0VbTL3JJBjaE90JWB1jPTR5I9DO4G9JZYCNpp5YIQ9+WLNAD4cGQ0LOlr/qN' +
            '58qOlukI3wqJ9lnQR/OjkHeCuxB+GnIRgG7Nz0E+DJYi/CrkY2AVwisg3wCyD+sg39Mxfw0Je1s+' +
            '0ftjkfc26L972rIJQJqhQ8sWABuZd0L+rGOW8j8A/TOjvxb4iuUgwr9BHgGXEUacFTOCVdP1YsXe' +
            'xoq9ixm+ZoVOrNI25ZCwj7UewlhDrQ0AdBQUA5kO4IdB8BNrJmiGcAJkCwC9BcGvrVk6QS7ItqA9' +
            'wm7IzqALwijXmgdg8yBZ9k06QWmQsLsVvhbUEHKwTpCsczSAbwehbiv0bIWegzpAQs/WBxHOhYSe' +
            'rY8g3BMSerZCz0G9IKFnK/QcNBYSOrbCR4IwZqwfAug5CDa1Qs/WbxCeBQk9W7/Vf8+3FXq2wn+D' +
            'UJ91u07QPZC/A+g2CH5phW6tGItBD0Ce1gl6nCgc4zr8S4SfgES+cIyXoI8hL+kEwU7hXnAF4X1E' +
            'UUgfBZsEoexo2CgWfhUMHceh7XHIa/mACKqmhGd1WyYgfQLKsaJ8DCGyS/vA3+3Yg9rrEIUEQcIe' +
            '9k4IYwayQ/d26DwE+rTDn+03Iwy72Yt0QrIhB+iE5EAO0gmB/ewYi/Z5CEPndujFjraEYL6yw1ft' +
            '8M+QJyExr9nhjyHwbftusAdhpLOjn3boJ+RTyDMAfQyBTu3ngQ/h7fp06BiJ8K+QmEMcsEkofMeB' +
            'Oc2BuSkUbXNgDDmWIYz2OTBXOVYjPBQS+nHAlqGTIdfohMp8stwDCMNvHIcAdBMKezlRlxMDPRRl' +
            'OUMAxnroC5DJAP4VivxO6N0JHw5Fn5xoh7MdwhhvTujF2RFhlO3EnOGEH4fugoRenZgrQtFvJ+Yv' +
            'J2wXijHoRJudmA9sGGfOFTo2jDMn5iwn/NKG8eb8UMeGudoJP3RiDrBh/Dm/17FhfnbK+n5CGOPO' +
            'uVfHhvGF/wobxpeLA4xrG/rjQn0uzHU29MmF+lw1EG4EWRNgzrXB7i74iAsOZWsF6dCxoc8uWRbG' +
            'n60NZFMdG+Zql7wHXdjQbxfs4UKcDf12GdjgT64CHRvmSBds44KP2OBbLtjWhbXChrHtGg8mIIyx' +
            '7ZoEsF7YZFqsVy74mA3riAs+5sJcb0M61xIdG+zowhh3SX1inLpeBlgHbJgPXBjXLqlD2NeFMeeS' +
            'OsR4dGFMu2BDm8y3WceGOcKFMebC+LVh3kZ3FTaMI3c1AJ+wwZ/d0IcbN2wYb+76AHOV7UVIeS3t' +
            'CB90r9axvU0EtVMiPmy4TkR/EschjPGQhPgk+IkNNkuCbpImEoWhvCT0MQnzaxjmruRUnTC0NRl5' +
            'k6GDMMxDySgjGXNV2Daiutk6YfAxNIUaYOENw5zfwKIThrk/DfN0GvQchrrSpuhUhy81rKFTHev+' +
            'a8i7Ak+21TFfrLwPQLfh8GtMReSF30RhDHqRx4v0UVgvvPATL+b5KIwhL/zGCz+Iwrj1ttWJhs95' +
            '0S4vyohGm7yYI7wYI9GYf7zomxfzcTT0Ksp1oiOJaQvA8whHQb4IYK/oJpCbAfw8uh8xrPdMrvPR' +
            'I4mhe8yCcRC9BNKuoOhVFKT+4pXc4lbd5cqfDOj/OP39Pz2nhm2MmYKwSaiGTYCVQrBns1EYVadw' +
            'iqBIiqJoiqFYqkFxVJNqUTzVpjqYju2YupwYgm6YP4mSqS7Vo/owTwqlUho1pEbUmJpQOmVQU8qk' +
            'ZtScWlBLakWtKYvaUFtqR9mUQ+2pA3WkTpRLnakLdaVulEfdKZ96UE8qoJuoF/WmPtSX+tHNVEhF' +
            '1J8G0EAaRINpCA0l7I/oHrqX7qcH6DF6il6gV+hlepVWwNQr6XV6k96gt+hteodWUzG9S+/Th/QB' +
            'fURr6GNaR2vpM/o85BJNp5E0isaFeGk2vURTaULohzSLxmP03kfP2FrTDNtA2yAaQ7faEm1NbI20' +
            'fFsnmkhztWa0ij6lO2kETba1ZH1sfW11aRLNCxHYzy6kRfQki2YxIcdDToScCzkfcjrkDH0StpS+' +
            'Yq1C64ROCI0MjYr6LWpPyGW6LeRsyIVQC91NS+guepAW08O0lB6hh+hxwsikZfQcPU/P0lk+ms+l' +
            'aXw2v43PoTl8Hr+dj5F2ZJ+wpfJnNXwxXwu9L5FSDMKOuQmDD/AQs4nLf6ZDwQ+J9lSOkdd4uTR9' +
            '5x59HbCCQwjNIVqovx6fOpTYF/svyLv/CzdC+Q8KZW5kc3RyZWFtCmVuZG9iago0IDAgb2JqCjw8' +
            'L0Jhc2VGb250L0VMT1JaUytGcmVlU2Fucy9EZXNjZW5kYW50Rm9udHNbMTMgMCBSXS9FbmNvZGlu' +
            'Zy9JZGVudGl0eS1IL1N1YnR5cGUvVHlwZTAvVG9Vbmljb2RlIDE0IDAgUi9UeXBlL0ZvbnQ+Pgpl' +
            'bmRvYmoKMTUgMCBvYmoKPDwvQXNjZW50IDgwMC9DSURTZXQgMTcgMCBSL0NhcEhlaWdodCA3MDAv' +
            'RGVzY2VudCAtMjAwL0ZsYWdzIDI2MjE3Ni9Gb250QkJveFstOTY4IC00NjAgMTU1NiAxMDcyXS9G' +
            'b250RmlsZTIgMTYgMCBSL0ZvbnROYW1lL0RHSU5HWitGcmVlU2Fuc0JvbGQvSXRhbGljQW5nbGUg' +
            'MC9TdGVtViA4MC9TdHlsZTw8L1Bhbm9zZTwwMDAwMDIwYjA3MDQwMjAyMDIwMjAyMDQ+Pj4vVHlw' +
            'ZS9Gb250RGVzY3JpcHRvcj4+CmVuZG9iagoxNiAwIG9iago8PC9GaWx0ZXIvRmxhdGVEZWNvZGUv' +
            'TGVuZ3RoIDg3NjUvTGVuZ3RoMSAyNDU0MD4+c3RyZWFtCnic7Vx3eJTF1j8z72422YSwIRUSsrvZ' +
            'JJRsKOkhldBLIBQhoYciCKIU5QoYQUTBELAjYgNFsbuoKIpYAbl4VUAEgetFUFlsCN4AEszO95t5' +
            '3w2Ron7P8/3zPU/w+eVMnzNnzpxzZt4YYkQUTAtJo04T5tzg0I6ZdqDkbSD+6hmTpzd/reN6pP9N' +
            'xCdNvnbu1cdY8mIirTuRpXzKpMqJtUf2dSSyPoI2WVNQEHBP8Hzk9yKfOGX6DTfFPNu2DfK/ESXf' +
            'f+31Eyqpx9B/EXWuQX7V9MqbZlgP8kSicoAcM2ZNmvFT6J3LkMf4tG3C9MoZix8/G0FUEUIUMGfg' +
            'kI5p0x/7Ty+iseCBhol0cBXHD1IVcTLRVJpFc/DfAnqQlgPkIbeHwvt52peVe/rOqfCQqyjGE5BS' +
            'XlChyqoqHHs9LLxDTKqHuR0HPSEpqR7u7je4vIerwpnq0dzXxDg8xWXlTk9xRarH5JZdnS7nvPKv' +
            'Yj+piEW78vrYnytiXU6POaXc03NOhaqoqMB4ZnezUSNSPQHuDQlsKWZ3LB01KtZDGMbi3pCoioob' +
            'igLdLcIcuR1TPUFuR5WcZCuGcXi0pD4uh8eU3NdDZeXVk6orHTKRE+t0VsRWq9xgPScntOrc2WJt' +
            'TowY7HbsUcsJcTs6eiwpo8odjl6unpVTHeWOieP1IWS7ZnJmTO2odvSq7lnpqnZUu9R0Ljm4pxgt' +
            'sT5Z4CmeJDPoE6pmKtgX43TGOvZVQwzo1AfcXGXw5lTNmrtdjn3G5C5Heb8hsU4PqyivxoL6uKpd' +
            'juo+1a5K2UHvIkmqxya3oQX4DpMLkIkWFy2gWhJX5dRxjVciu4a7sYjqJVJsfSe6qi0eR1l5fux7' +
            'qIlwv0rFrLikhPXbZKMJpH7KxleVy5+Dy13jwb2rJBaEuUog+eLB5a+Qg7pNKHmFORiIxzHB03JS' +
            'nH+uSLcHpZALfqRCEaF95fgxkR/AKbIQpYc5w5KcYc5yHuKbwwJ9v/ED9W2u5s2IUTFa76N70Y6y' +
            'I12Z+1bee++9sn9r8T03871kIzuRKaEDz8zIzkpPi46KjAhlWkYH5koIiIyIZ+lp2VmsfMX4zKj8' +
            'kjm3dk2LyiiJbe/K6dQqxVXQskV07tQFQz4uG3nNoPfKqqaxvGlzkmbed/XspK5phLlxptg8vk1y' +
            'GO7KTMtOD3OdeG6Tc3QN+370gvo8km3iwYwGPkBZRKhmcUY6C1l2IcvMSAYHrZkrOTMDfEVxLX3A' +
            '4P425vbFm3uMuLE4s2OnzDvY/Otm3Mb+mzeua3bXhKrxs4sGD8zLLCjJiw4OnVE1T40fq9a5jWKR' +
            'iXRa5FCREQGuhOQ26VHpaVlqGosrnH3vOxSdWzJ+/opZk2/l1ebRmQUFmd2ibyni26ruT1k6ffaK' +
            '2aPLexcW98liy9S4rcG3DeOGyHEDuMWVBaaznZncdssc6/JW3SInO3yP823XrfJ9/8ynyzs84qqS' +
            '+6ZRFPhphvVGY79T5JoDLPFM5wgLze7A9OUGJARESP4yLHIbohSj7HTnlILsmutn1GQXdHLfOmH8' +
            'ra+Oycvr2CFvWlpB/tUF+Twip1u0c1jRxAW3TCoa5mzVPX3o9Omm9MGZGYO/K87KLCxMz+6qdKcV' +
            'frwL3bGQlSjJaXGx9HBXMGenfb90fohpT/++umLs2Pvuk0rEbKy17xusdyD6zECfYOxlJDYpzCl/' +
            'Rn7HltUf5s19S9ho1mVLFT9Q9VSVkk9ftO+L9kFoH+YyWn+9kpNvJStiXXzb/U2Ntp/oY0NHw9LD' +
            'WHoQc2lfr1zJWm/wfcVKXv2ltpYf8L3Hin3bfZWsBH3K0Kcb+pjl+JKfY2y0rxlYXgcmUF8CYQci' +
            'FaLPnx7LoH1hmuvLlV8vXnh05a0reU79DjR/m3evbyPTur7yB3SenUx2YpIX4Tu0cjVzrmS/+TCg' +
            'z8ZO1rfRz6Dk4Sm0t1NbyDFD7lGK7OdMi+eREZZ4c3REdKSrAwuX5ZHYTfYzd3d+YSVbkjOoXYv5' +
            'sa1ig4I4c6wNDYrJyNq4MTOzKj6hWYd2vsP8QHJhUcLiTsHN4mOKCwvat4ht1YltzEl6J1nJKxTz' +
            'DlP7R3I6V6Yzkt268ivem4+qX8dHVVWhTQzaLEGbAKzFpcnls+ULzjz4xOMPYtGHeJLkPw66GIKk' +
            'g2BUoqUCFrG0QnNmBk4eFDo9LTJMLiA5MyA7M6A5C4WeSp18r++Ix3N4orV1SFjAoIz25iXNDn7l' +
            'WGXr2ye8bSd3YjtXZpfoij53xVrNWkBgs7DgLEf7zU/79ia1DotIKD2ZHBQYFJRgj3eV6DLMAw9F' +
            '4DOUWmI1xuFso7QgK0rpvjqlbFTlokWVE9JqatJumlLSNTOjhCetrZq3bkA2tqR+4I2j+5aOGdO3' +
            'nz6mfsaSMKJdjhmvYTOc8RpMWXoo0w9atDRwFmZzlfRIdzDoZFB0akJZbHX00pGzF99x2JzdeVQo' +
            'T7K17zqtR0iIPTUlunvZ2AcWLX30WF7xfLUH3TBRa/AdjoyUV2SYYjldbn2Yi90zrGNBTU2XiY7c' +
            'bEcN6zsxv4PvbXB6enhYmwGZvpU6nxiDPvPbcKml0kJ/VlNTw+Pqv+VxW6qM83GhnWr1WY08mcjL' +
            'MVxYay7WaqXIC/JLtmVFGwZE2o3UBcvvnl+1YkVVbs+euTm9evCkh+5ctOohZn1o5rjV48b2Lxur' +
            'z1OEH7MwFvQrPD2yELY/OhLmEespqokq6xQU2DJ8Pnibmp3PVpjm+44oO4j5A9EHGpQtvYWcsCNL' +
            '6GDR7Vi0K1k5kig7k56FY2+ftqTkd86ObLWeRQXFNIsIDgn4x+TpN/MlbGKSO6L1hqlRncd3Oxfw' +
            'aEJiXEtbRGCGxRRkbd4iOj5sSGXlsD6x0bawoHT7Nfa8Lq7X1FkQ37NU/gRFSDvsCpNrzo6ECDJx' +
            'LNIz0yNZ6oAWccGRCR3v7NGjhoeN9h1MjNbGBy9g/Uffc48QZPyzcSldkrEpSzu1etbU6rHN80/z' +
            'YO24rN2x+eU6P/09x5cREGHqhLaBRg/1Uzvu20sjzF/9nlOfGBBhlDf8C3qKvy19NrYMP1kUUEoz' +
            '2EFK427SgChtLkXxPZRNJygNdW2BKHY7RfPeyEchoCilVopGEUf71kB3IN5IxwCxgMPIRwFx6DNT' +
            'AmO0leMoOoGKtc/Qdg+1AgYDbqCUP0wDUddXs1J75LtjniI17h7qi/IyrSuVyHLUt0Xb/qApyJch' +
            '7UB9KNL9kY7RPNQMNAqIRXk85i9hUaIWtAXmL+Bu8QPSYZI/1OeBJoAqnlEeirTMd8P8EiaU58k0' +
            '5JOP8iLABXQB4iAfyWNro18XpEPBlxnUBgSxWopEmyQWQxNBe2P+fEP2JahPBOxAK8As24A6UdeM' +
            'HxG/slmqrhx92kjZq7JSjDuGHkRZDhtLNqA5yuYac4cb+xTL3Ni/6dg79NcmUVsDzdEuw5D7JYCm' +
            'MbUXch8aAbI7I/cC9GfgV7Qh/z5cDPA1ENSu9qIx5F5gz6RcldwvA8g3Tu2FrjsNMObv1jC/Ln//' +
            'PvwRUscmULCxPxeAvWige5S84y5D3Wr+K9NS/jn0RK5f6ouUj1vp2eVopD+v9Bk6dSUqZanksocC' +
            'QQOxxgPAl1gzAwIMmIEEA0VSHnwQ6DElzxgpG3VOoKu8o9LTMtWmMX1ap2gjqbIBxtxFl9AtFMF3' +
            'UbpMq32FbC+hx7Fnb0LmOIPqHPyRZqtz6VZyujzFmTXOTSh7zKClxjmWe/U3qTzv6sw9rOxPUMO5' +
            'x9m7mOrzCaF9iD19D7ZHnv+XxY8oO6j2+SSQpvaEtB3KLultKnGWHla63ZavUfYmXI6l9hDzaS8o' +
            'W9GOLcPYVn0fWKnw8mspDPxJXpv5ZamlYIy15DINB91Dwdq9mEeuZwn2zS+btdifNylR8XuM3H45' +
            'aZFY8zq09Sn7ma/1AsUcDevUbW9rfjv2JRe2uRv2EfaWj6NsZoINmgUb05tSwesMcyaVmrYDw6m1' +
            '6S7Y17m6bph8ONvHgblqL9XZgH79CPzg3/u/vUdu5VP+cM6knZFn/TLnQMntYj3zr0nqeGOeG/rN' +
            '0f2Cob8Xz2FX9kAvtzXwop/NMP8ZxdjLgGr/WbuEB6XT4kAjHZfrS21Y58U6nUstcTbjG8727bDr' +
            'cn/+OH/UFc+Wf15Dpw0/FMefwhxPw077/VY51jYTZTMbfG6UVgKah/6p5NAyUN4FNiMfvExTfi2B' +
            'Zykba+V3UwjKuij+pL+D72LlBkVsz5tTBGsPv2cFqqBrc3XwG7C+WZDBZKTHUKJ2HdALvB6lDPYw' +
            'fNVK4DlKZjXUU+Ej2KlD8HXXov211JWPVzKKYf2ohaS8HWmsN3yWlNtt8FH7wN8C5R/9vjRIpnkb' +
            'yG+goeOLUC/12g/dh7t4e8wxAOdpCvIjkW6L2KY/+NmO9Czl71V77SfoTx30vg9oIsYehLl6A+AN' +
            'NqAbfwRoRiHYwwh+H/Z2PTnYXB20E7zasD4b5JqCmGgZteNRsC3XkhX7lIG5MozY4RqFUroBmAAE' +
            'GQg20NJAoFG+QPp36c9lfILxJypaSgMA6ddLDYwBhgN0EVwqptPbpML+nAX2qjofjWA34H67h7qw' +
            'aZD9jRh3AAVw3HougYVyJWQcYszf2+AzAggx0F/xtBH1G6kju5uiZZxHO3B33YF5dCrXFK9D/ETk' +
            'e59ItAPdBLwIbCeqfwd0H8pxs/R9CHyLNKJU3xLgbaQ7gH5v5PcZOIXyQiBPj219dXqZ77AO+Uoq' +
            'piC9FfiiEeTY2cBdgAv594D/Ih0P+inwNdKZoJ8ZdZjft8GY83PgOYPH3kA+0AmowBoOAt10NPTf' +
            'AqwBXkUZboH1m3R+1Ppf1Pn3vd6o/TtGn2+AO4CHgNsAub4Fxjoxv8BNzfcK8DAwGpiOsU8acnoL' +
            'GIn8CdDVwDrgGUPWEquMsm3Ak8Bdukx89wHP6/z4njL2Z6ohz08AXBd9j7L5iDnnQ39KaZGK66fR' +
            'aKlb/JzSvZnaOPFPbYnYx7aLz7U4cUA7LPZrE8R+Jm/YGJEvBPoAkCYvhQ3rAboCfrY5lrYf6aUA' +
            'NEIrAAU3sJkEm6K3l2n4RNyzSMM9STMDIYAVZRARswivLOf3y1sxgJ1hE0FzgJv0PGyHBj/OZD2T' +
            'se44lMlnQmgRx90V9oJ4TyG4fA1iKsYjLp8qh6DtANB7gFR9THlV4zeJH/hWnQes8Wc113CjXvLV' +
            'HXbjGGKDCvFf2L1Y/oH4iX8Le+0WnytkwT7DzsP2RfPHEGcAmkP5+cF8J+wlfArrQoOZW9TzYnKY' +
            '+lMH0wi0SUabb9HmNPAR7OWvoB+CynhGj2kGa4thCzGeKQN2Xvqm00Z72e8A7PVU0FNoF4B5QPmT' +
            'aqxEdY/CmNpSpFdThNYJ5W9RvsmJsW5H+x6wkXsb2ieYeoBuxdxt0X4Q/DHsL1sPW/si1lSAeUJh' +
            'v+GHlK+QkLFpDmzqatCRuv9QdCKA+xDbhLGSyKptRXkseK9BeXuMMwe+ZwfSm8GTVY0h2zu0MtC+' +
            'GA9zKYyBL1+vj8VTID+TvG/h3hRKJm0RbP0i5QeiFB+SH8zFR2Hsgxjja8xbTD35T8gHqLEStZeM' +
            'cqOevU+Imn3zDJsFuyGcOG+vASai3wX6S9nkw0fLu1ZzJSe5tpuxj5tAr8N97X2UL0F5IeTaG2O7' +
            'IKPnITvwy8+ivADtDoJKX3YE/KWgzc3Yl2ewL7koXw7+vKDn0X8QDdIeRV7Gsz7wLGPYDqBXY57X' +
            'EXPehv4FGF/SkVjDY0gnIr6Rcj5KkVozxCeTqZPcY/jJfP4y1t+fempHwM85yNegUg+lLmnt0P9t' +
            'zG3HnC0xzzz4Yqk/2EMtHfRBjPEBxsRY2nrkd0H+XQz9zEB7SbMoGf7XjL1IVHpfYPBdYNy1QNVc' +
            'oSqmdyj9kT6/LSB1WO6bQRviJf9+GVTqpnqLeBuxgwNr3wLEKt6DeEvEUm/peiXPCvNgHOi00isZ' +
            '2yeQfFdL5F1VjJmC/UtUd4xA9Pfvy0HI6Z9APWLAk4hptkJmTqz1pF6uDQd9CXX7Ef+sQ/5WoA9k' +
            'uRVt71f67+I/Ypy3QE+j7RyVJ74Mfbxocw/ol5Sm2ZGW46MMNieVvwq+5LwLYTeexZhp6LcGZyIJ' +
            '9Ffl/yfQf8hGdTBhpaJe+e9x8MNTKVC7BvNNwljzEAveDDoI+QXosxbjyfJ7gY8wTiV4LsTY3VH+' +
            'GPKybizSMr6ahfQ09J9KXVl3yEPWxSGmHYj8UvBxDe59XdFuJMrLAbTX3gCV7SaC51EYV+anAGPQ' +
            '7rw+pvInK9QLYgpMKzwBTQJuMfI/APCxBO9Au4wHrUdRx2U5N8l3Q3qftVPfCKplXxWLEDPDjhZA' +
            'pqXQoY78FsSsz9FA2Y5t1tNYX38WR31g3wth5+U7RSHOYhnsaDfV7kXUoY08c/wB6o29GwjeY/nj' +
            'GHcN2pXjTtcb9bXo1x51yWgfT33UG9pBSlO+dp7YynJx77tVnDXdLs5qT4id2nbxG68TZxUOiN+0' +
            'pSg3A0uQ3yfO8DWg34kzmnzveEec5J+DbkS5R9Tytah7Hv1fQvojlD8jzqPuNMY5y19F+evAZrRd' +
            'Db/zKOjzKH8FZfeLOn4f8BrmMaFuLcoOiXNaB/EpfxBt3lNzneXVohZ2LYeli59YJ1HL0kRLstQf' +
            'NrCJAutrKKD+KJnrVxtx2RL+gvhVSxUf8I/FOf4Gxt2Gu++b5IRex8L3R/FXqAW/A/RmnL88xPDP' +
            'gX6K+8dBakZBiL2eEHP4HvT7DTIaRiYZi0HO+fD7+XyVuufm89mA9AN5gJT9AiP/hvIj+fDnZVo3' +
            'lKMMd4x4xPXSxpdp2aA/In+1Pgb2Sx/rIUpDuzKcsTI+TOXL5FxqnDmIjW/Eef4Mum4CMoAPEMd+' +
            'DPwb6euBj5A+oee1W9T9W4HvAP0ZOAtt3KFoPOKaeOgRwf6pMXCO49luAFEx+xr5u43+PyEdYozj' +
            'UXF7PEdEyOTch4EzwGmDHw33qvdpAHQ8nx8CZuDOW0MhJhvuO82RX0EdtLGwX9K/RcNu7IQeybjk' +
            'AeQfw5mdDLuZgrilFdrKu93n8JFbse75qBuLO8Ap6GwR6rIoVdsNe/wObK28R02hVrhjxmpR1AZn' +
            'Ogl+pw1inJNKpnfCRo2l9qbJqHsG/VfBx6yhaNzbTTLN30f9G5RrSoM9XgN9WKPePMLhO9xc+u0i' +
            '6oIz4IPfbwd7G8Rvg44/Bp9xP8qWouxpaq8th/2ehHur9AOHUbaY4qAw4er95DfwUgBeZXxQC8yE' +
            'TfoCbc5QG8hFkzxj7e1xds5C5imKp+8oTpsnTsAO5Wqfgu/N6HfhzUJ//7mUXngTnKDeBP+c/vlb' +
            '4QU6gfo2vCv98W3wYprYOI8Y56CBX403Wv0t8GL6h3dByFanZwzqlW/s6p5/Eb3iO6FB/8Y7hv+d' +
            'xP8+dLk3Qz+1/OXb4eXeEC+llr/9TvWw+n4R6qf+N8W/ouo7g3xXukBjjbfmy74/qr0qVfcD/V0j' +
            'RX0jCf2TN2mOu8LbGPdK9X+P/qX+wQ64xY4r1fvfnP30T/Y7hE8QX1+x3nj7/Ct6yRuv8e75V/QP' +
            'b8CXozcZ98ErYZMOrRL+bJA4hXvsSa2NOMUPisP8hDiq7paXwxnxC3zXT9oW8YP2MujzoBsgU3nH' +
            '/BNo2eIXrUicMnHQc5jzB3HcROK0ViM+0ZaL3bhXCnk/ZTeKE+wf4jibJ35gc8SPbJY4whaKr5D/' +
            'hi0Qx/lQcYR3w/0yH3fSYvELOyg+Zx+Lf8K/0eWgOcSP2mThNeWL70zZSH8mjmufwIbnGHfmK0Cr' +
            'FidNOeJX00jxs7ZbfCDvuX+KHuI7bRT6JIsfTJ3Q5wNxQjsA2awWu7V3xb8a5O6XoyEXtea8Rjz7' +
            '5zfG/at9hI8Ar0SmJHHGFIx9/BL7eBR0hdin3Y9456/25QT24yz25TXxi+kNrHcd9uVNcdrUW3xi' +
            'GgTe/2Ld2M/vTDFY9zdY90/iZ9Mt4oTpIaQHi92mOY3W7cf9l+og34S9lLq4TH2rGcpGUBdFo8RA' +
            'xPanG/jt1IjvQLFXaymOagPFfm2Y+Ar3Y0JMMZR9D1RTLBsoDrHx4jt2vTjGZiC+qxQH2HViF52E' +
            'bmniNHtCHGZrxH52hAbxUhqEeb6+RA/ke4iEf080A29g3n3isJaMcS+8SQ6+rIyWiyNaO5yTW8Fv' +
            'LnRkj2p7I9Y3CHaS5FfvBopxSH79Xo/53Pp3K5K/sTmRLvtPfaeW30vd8PGAdhwxLsA2yu+rOD+6' +
            'HStpQC31Anob6GN8k41jYxDDj1HfSopxXxsFXkbJ9OVnNebWeQ42D6dg3AEy2HOUgbt4BtI2Nh/+' +
            'IQ/0A3k3oyFAGb8O94jVNANt5JwMd7AECfY6+O4Nnu+mTFovhrABNE6+15q2UzF8j8QM5f9aIu5B' +
            'dC4hv9Wrb+2yv/xuPw93rBz1hpWAu3ow4sUk3Evl998k/gUl0degMj2KcmVa4UrrGkvhkHkGaKiB' +
            'cOP7czMjHeEHfUmtcFsLZ0tw35N1qYrq36qv1H8M+o6hSAnV/0tqwaah/Dq0qYb/mUJWNkH59XDc' +
            'NUNUTLKfOphOUZmpJeTYHbJYiJhoNPzqQPitifJ3SOo/1iGgNSIc6XsB+a7aAnQEgPJ63C/r2wNt' +
            'gbFAgfHWOlBv50sl+j0X5c8CuKHXQyPr1xrj7NI2IMbdQYkmK+4AX5BD+0F/t5PxofYgYnQZo41R' +
            'ZzNUm4m4wUt52ijc/zcjHj5OHcwjyA7aS75h4lzEwua5EY/K31trpfxvf+jDRXdYbTK1NT+oYi4Z' +
            'xzkUZPzxKAWapNyPYr/17/22RrQ5EGrk/dRfptoZv29RhNi+COsqUr9LsYFiTB9RjPkrlZZlUaBR' +
            'KItS35KN392QcaKKK92IDUp0qDiqhEJN5RRqvk6lZZkN1IYym9Fe/e6FijW3IjbfyopB2xvUn38M' +
            'WAZUG+k2F8BK/kgbykMN2uxCmmoatfGna4wYScowD3KXv7MXqJVTO/m7KpDLTj4Y52scbEei+v2V' +
            'VPX9tBb3l9ZYC/ZS+x33jYcR98yCfr6Ou8oQ9A8EvSiPs5mMebKxbwpIjwMWAcPML5KdjaNEbQrl' +
            'SPBd1LsBq6gTP2nAXzaUsvhboMeAQp36+7Ico418b9ylfuckQ9XHoY+8N62hTtpNkHd35ENQhzbM' +
            'TSNkHjQH9/IitpiyGnjBOCwDYy3U86qsDvM8g/5y/DqD320Gf62ppZaPsbZjTkmPqu9HbdU3rwiM' +
            'PQx2lWNMAGdoN3AS5+mMfIMns286Bfl6gabyBeIcBfiSyeJzAgkUiLTZNxu4G22moC4V5cOBpaib' +
            'IvuwXjj3/0G8+5o4xdLgX7xkge0/a0pU7yxntBjcjbYhzvkCdBPuPU8abyMv4y60E2Vb4Fe/QNlG' +
            'lG0C3kWbR8R/+ROgz6Fcvp88AHwA+9wc5U+izUMol31rRK22GHPJt5y1iBH2o64edbXAbvGbfNvR' +
            'QvQ3HtNccVatU8cUINVY93R1p4KN5MXASJybQTpwvw41HaKupp3AbmAfdTU/Q13l+xXrDBsTD9+1' +
            'nIZBpwuwv0XaOhqolVJ/7QEq1J6iMm0wyk5QofwdGflm1RjKxvhx8XvZKApkm+Gf5FvZeJyLxm9l' +
            '8p3M/0bmfx+7zNsY7VXfX0p5MvI5aLOThuDeHm64l7b/Byg2sE6PDljbRlhoQEZV+X8DMy7CGuBf' +
            'l0J+BdIcwFBg8UX4XYfJYaD7/wLg3xzXCAsbYSvw0wUEBDbC0EZYSmRBmaX3/wLlTWhCE5rQhCY0' +
            'oQlNaEITmtCEJjShCU1oQhOa0IQmNKEJTWhCE5rQhCY0oQlNaEITmvD/Hkz+xTT2LDWj2RRIHHku' +
            '/89v9UfVAsm0iYnbPWw59fMElpVvYGxFxYae8q/RemwV/TwRg5FYWNHaE5Ayqpw8JkcPj5bS3WN1' +
            '9HjF1J+nqEyQo8dbZF0gyMgHojIow8hYkAmMMzIByFhCjIxZdgtgc/zdgmXexPKMPPOEGJM1Q6+Q' +
            'Ip6yQes5B9lQ2S5ETaeXVHgiUvTfvdMMxOmLM12LHFN5k0n+3wM2ZCxko1vYZnaa23k6z9au127U' +
            '5mm3aNVajbZW+1Tbr53STpsqTbNNC0znzOFmu3mYeax5ibna/KZ5q/kHc61Vs1qtNmtbaydrujXL' +
            'mmvNt5ZYe1tLrYOso6xjrDfa3rOdtp2z/R5eG/9w/Dl7pL21vYe91D7cXmEfaR9tr7K/Zt9q/9x+' +
            'yP6Lvdbuc0x0zHSscNzveNrxjOMFh8ex0bHJ8bljv+OI46STOTVnkDPUGeaMcEY745wJzjbOFGcH' +
            'Z5ozx5nn7O7s5xzgXOB82PmMc2cCJWgJloQWCZEJrRJSEsYlTEp0JX2c9EuyO3ly8vVtilMnpV7f' +
            'IXp9zXnz+ejzWefzzxee73q++/mBol793T4HrWHvsLM8kWfzMu0GJZHFkMgK7Ultt3ZSqzWRaYbp' +
            'ZtMis83cytzZXGGuNN9p9pg3m3eZT1qZ1Wxtbg23tremWTOtOZBIobWXtR8kUgGJXG1bY9sFiZwP' +
            'XxNP8WvsZI+xO+y97WWGRMbaF9pft2+377N/Zf/VfsZBjhmOGxx3O56ERJ4zJLLLsc9xyPGdkyAR' +
            's5JIuDMKEnE4k53tlEQynV2cXSGRUucQ593Ox5xbIRGeEJAQ1iCRiZDITiWRccnXQCKdlESWnqfz' +
            '4edbn8+BRIrPdzvfU0pEfCM+EO+Jd8VmsUmsEY+IVeIBcbe4S6wQy8UyMVvMFJNFhRgkBopckS4S' +
            'hEPYRbzvnO8338++43X/rjtUt7/ui7q9dZ/X7anbXfdZ3ad1O+t21G2re6duS93rtTW1VbXzauee' +
            '2uf92PuR933vu94t3s3eN72bvG94X/du9L7qfcW7wfuy9yXvC97nvc95H/c+6n3Eu8K73FvjvdN7' +
            'u/c277Xeqd7J3oneq7xDvUO8A72l3v7eft5e3u7ert5ib6E3z5vrzfGme1O9bm9bb4w36tj5Y9uP' +
            'bTv24bG3jm069tqxdcdmHJv+recb61Hv0eeP3nT0H0fWH9p06OVDgZWrQqeFjgmtCC0PHR46LPSq' +
            '0KFB6y/++4tN/yhA/t/HyoZeLBtpXfV/nP78n95TIxOZKQB2KZCCyErBFAJLHUrNYafCqAWFUwRF' +
            'wl5HUwy1pFYUC2vWmuLJjjPrpARyUSIlUTK1obbUjtpTCrkplTpQR+pEnSmN0imDMimLsimHcqkL' +
            '5VE+FVAhFVExdaUS6kbdqQf1pF7Um/pQX+pH/amUBtBAKqNBNJiG0FC6iobRcCqnChpBI2kUjaYx' +
            'NJbGUSX4v4OW0J20jO6jVfQYPUlP0Dp6mp6i9fQsPU/P0Qv0Ir1ML5GHNtCrtJFeo9dpE71Bb9Nm' +
            '2kLvWHbSLJpIk+gay7/oJlpLM2ha4NU0h6YG7qKltBozzA7cHbiHJtM/Aj8K/BgCKw38jK6lm7Us' +
            'eobeoltpAl0X+CkbCmf2T5pOVZZdNJ4W0e30IItgkZYtlncs2y0fWT6wfEhvBu6l91kXy4nAHMs3' +
            'lm+Drg2abvmY5lq2WnZYDtJiqqHbaDlV0110N91DK+gBkn9c9n56hB6lh+m//Gp+M83kN/G5fB7N' +
            '41V8Pp8s95H9h78t/3Yyr+abIfcaScVodpg6y7/qwIMtJi7/mb7loaKYjiwgsjnk1vcacBWMHTlE' +
            'veYQOfL/tmLuccTe1dXjfwBJBaEhCmVuZHN0cmVhbQplbmRvYmoKNyAwIG9iago8PC9CYXNlRm9u' +
            'dC9ER0lOR1orRnJlZVNhbnNCb2xkL0Rlc2NlbmRhbnRGb250c1sxOCAwIFJdL0VuY29kaW5nL0lk' +
            'ZW50aXR5LUgvU3VidHlwZS9UeXBlMC9Ub1VuaWNvZGUgMTkgMCBSL1R5cGUvRm9udD4+CmVuZG9i' +
            'agoyIDAgb2JqCjw8L0NvdW50IDEvS2lkc1s1IDAgUl0vVHlwZS9QYWdlcz4+CmVuZG9iago4IDAg' +
            'b2JqCjw8L0JCb3hbMCAwIDE5ODQuMjUgNzE3LjMxXS9GaWx0ZXIvRmxhdGVEZWNvZGUvTGVuZ3Ro' +
            'IDQwNC9SZXNvdXJjZXM8PC9Gb250PDwvRjEgNCAwIFI+Pj4+L1N1YnR5cGUvRm9ybS9UeXBlL1hP' +
            'YmplY3Q+PnN0cmVhbQp4nKVVS2odQQzczynmBLL+HwhZBOITzAUS82wIZOP7L9LPju2BR3ljhoam' +
            'C7VKNVI177y+56eNd+Egtl2G2vcUJe39+bLpUOUbODR6wmIoDGDCQ2LoVommchRaTdEAVGnSegNf' +
            '2Z3QKJpAoV1UiiiZFiFGlkU8KNIlKQeEuiUFutcrSSGjWMeDdAgPykJgBoUgkXIdvye1uXI/geGE' +
            'cmY5ZSC6ZU6CGFUajaPQZqNUxLfDSFGfdRkxytqjNIJKHVcKmHVaCf4aYRNqgb2fgjt4TYaQOcor' +
            'sq5mnFmSqVC3iTKTIzlElclgxaLJSCuxNc8pkJWtACsM1xAnhF3OdnALL7dw7CXeTQKnU2INdkNJ' +
            'ws+mcFN2TH2mWNoyBqxKdp5Eu7G55RsGu6Q8SbBF5tkbbhI3f+IO0hHXLQoeXhbQsOZxp4B3Tzo5' +
            'VmTaSd8thL8MPW4/ju3uXvZ66aDjcZOXJ032XDSvD1BQxX783b4x629mWUtnrV77X2vZWv56zhdm' +
            'e/h/Zh8YX74ff7afx/YP30dttwplbmRzdHJlYW0KZW5kb2JqCjkgMCBvYmoKPDwvQml0c1BlckNv' +
            'bXBvbmVudCA4L0NvbG9yU3BhY2UvRGV2aWNlUkdCL0ZpbHRlci9GbGF0ZURlY29kZS9IZWlnaHQg' +
            'NDAvTGVuZ3RoIDExOS9TTWFzayAyMCAwIFIvU3VidHlwZS9JbWFnZS9UeXBlL1hPYmplY3QvV2lk' +
            'dGggMjY3Pj5zdHJlYW0KeJzt0wENADAQxKD5N30z8KkC8MAGlAdcBIEgCARBIAgCQRAIgkAQBIIg' +
            'EASBIAgEQSAIAkEQCIJAEASCIBAEgSAIBEEgCAJBEAiCQBAEgiAQBIEgCARBIAgCQRAIgkAQBIIg' +
            'EASBIAgEQSAIAkEQCAPSB8wpH0QKZW5kc3RyZWFtCmVuZG9iagoxMiAwIG9iago8PC9GaWx0ZXIv' +
            'RmxhdGVEZWNvZGUvTGVuZ3RoIDE2Pj5zdHJlYW0KeJz7/38UjIJBBhoAF+STCgplbmRzdHJlYW0K' +
            'ZW5kb2JqCjEzIDAgb2JqCjw8L0Jhc2VGb250L0VMT1JaUytGcmVlU2Fucy9DSURTeXN0ZW1JbmZv' +
            'PDwvT3JkZXJpbmcoSWRlbnRpdHkpL1JlZ2lzdHJ5KEFkb2JlKS9TdXBwbGVtZW50IDA+Pi9DSURU' +
            'b0dJRE1hcC9JZGVudGl0eS9EVyAxMDAwL0ZvbnREZXNjcmlwdG9yIDEwIDAgUi9TdWJ0eXBlL0NJ' +
            'REZvbnRUeXBlMi9UeXBlL0ZvbnQvVyBbM1syNzhdMTRbNTg0XTE5WzU1NiA1NTZdMjZbNTU2IDU1' +
            'Nl0zNls2NjddMzlbNzIyIDY2NyA2MTFdNDNbNzIyIDI3OF00OVs3MjIgNzc4IDY2N101NVs2MTFd' +
            'NThbOTQ0XTYwWzY2N102OFs1NTYgNTU2IDUwMCA1NTYgNTU2IDI3OCA1NTYgNTU2IDIyMl03OVsy' +
            'MjIgODMzIDU1NiA1NTZdODVbMzMzIDUwMCAyNzggNTU2XV0+PgplbmRvYmoKMTQgMCBvYmoKPDwv' +
            'RmlsdGVyL0ZsYXRlRGVjb2RlL0xlbmd0aCA0MjI+PnN0cmVhbQp4nF2TzYrbQBCE73qKOe4eFlma' +
            'H9lgGpYNAR+SLHHyANJMywjWkpDlg98+4y5vL0SgD6ZGrekqpsu3w7fDOKymfF+meOTV9MOYFr5M' +
            '1yWy6fg0jEVVmzTE9bESxnM7F2UuPt4uK58PYz8V+70pf+fNy7rczNNrmjp+LspfS+JlGE/m6e/b' +
            'Ma+P13n+4DOPq9kURCZxn3/0o51/tmc2pZS9HFLeH9bbS675+uLPbWZTy7pCM3FKfJnbyEs7nrjY' +
            'b/JD++/5oYLH9N+29ajq+q/PLSnrDYnEpKw7kSrZBy2+qhwpbQWpJaVtIHWktFuRaikBHQrrhpTO' +
            'QdqS0nlIO1K6AKkjpXv8PpLS7UTK7SkdQ6pJ6XpIcCf08GgbUnr0ZeFO6OHRylmgx4nOkTLAYzah' +
            'DDWkQMpgISEDYcCJbkvKgCTcjpQBSTjpCAzoyyEWYUA4DrEIw6PVnpQhipTdK0OCJOGBARF6CQ8M' +
            'iNCLO7CBRy/uwAYefUPKBh69uAMbL1f3847eb/F91nRC4nVZ8nDIQMpU3OdhGFlndp7me5XJb/EP' +
            'hkb4cgplbmRzdHJlYW0KZW5kb2JqCjE3IDAgb2JqCjw8L0ZpbHRlci9GbGF0ZURlY29kZS9MZW5n' +
            'dGggMTU+PnN0cmVhbQp4nPv/fxSQCn4AAGf9M9QKZW5kc3RyZWFtCmVuZG9iagoxOCAwIG9iago8' +
            'PC9CYXNlRm9udC9ER0lOR1orRnJlZVNhbnNCb2xkL0NJRFN5c3RlbUluZm88PC9PcmRlcmluZyhJ' +
            'ZGVudGl0eSkvUmVnaXN0cnkoQWRvYmUpL1N1cHBsZW1lbnQgMD4+L0NJRFRvR0lETWFwL0lkZW50' +
            'aXR5L0RXIDEwMDAvRm9udERlc2NyaXB0b3IgMTUgMCBSL1N1YnR5cGUvQ0lERm9udFR5cGUyL1R5' +
            'cGUvRm9udC9XIFszWzI3OF0xN1syNzhdMTlbNTU2IDU1NiA1NTZdMjRbNTU2XTI2WzU1NiA1NTZd' +
            'MzZbNzIyXTQwWzY2NyA2MTFdNDZbNzIyIDYxMSA4MzMgNzIyXTUzWzcyMl01NVs2MTFdNTdbNjY3' +
            'XTY4WzU1NiA2MTFdNzJbNTU2XTc1WzYxMSAyNzhdNzlbMjc4XTgyWzYxMV04NVszODkgNTU2IDMz' +
            'M105OFsyNzhdXT4+CmVuZG9iagoxOSAwIG9iago8PC9GaWx0ZXIvRmxhdGVEZWNvZGUvTGVuZ3Ro' +
            'IDM4OD4+c3RyZWFtCnicXZPditswEIXv/RS63F4sjiVZ2UAYWLYUctEfmvYBbGscDI1sFOcib195' +
            'znYWavAHOtKMzjHj+u30+ZSm1dQ/8jyceTXjlGLm23zPA5ueL1OqGmviNKzvK+Fw7ZaqLsXnx23l' +
            '6ymNc3U8mvpn2byt+WGeXuPc86eq/p4j5yldzNPvt3NZn+/L8oevnFazq4hM5LE0+tot37orm1rK' +
            'nk+x7E/r47nUfJz49VjYWFk3MDPMkW9LN3Du0oWr4648dPxSHqo4xf+27QFV/fhx3JHS7miTmoaU' +
            'liHJPujeT3lSugZSS0pnIb2Q0rWQOlK6PaSelO5FJCuNQY/2VrqAHr3sgZQ+QGJS+h7SSEo/iFRC' +
            'KH2E1JDSI7ZrSdkiUHGsbD0kuR5sYcLDtzDAvW9JGdDLI4owIJDvSRnwJYpjZThAQhRhQKBiTxlG' +
            'SPAt3OPGYk+5d5AQRbhHoGBJ2e1kkP5NzDZT2+TrvA73nMuoyu8hM7pN55RY/6BlXrYqU97qL+cy' +
            '4B4KZW5kc3RyZWFtCmVuZG9iagoyMCAwIG9iago8PC9CaXRzUGVyQ29tcG9uZW50IDgvQ29sb3JT' +
            'cGFjZS9EZXZpY2VHcmF5L0ZpbHRlci9GbGF0ZURlY29kZS9IZWlnaHQgNDAvTGVuZ3RoIDg1Mi9T' +
            'dWJ0eXBlL0ltYWdlL1R5cGUvWE9iamVjdC9XaWR0aCAyNjc+PnN0cmVhbQp4nO1a0XGcMBDlxzMZ' +
            'O7G5XOJJPjKhBEqgBEqghCtBHVwJlHAlqARKoARKcCKQhAZ42pU4Yc8k78OeGxaxetp9qxVk2X/E' +
            'oRBvwRB1Acdr0E2zSY2GzafrJXzwJSkVXTgTCr3YZgNN05lFOQCTdrqeY5fqlExc45hQMIvookDT' +
            'lNYEzrTT47XwideUTMBF5KArVuNJYDrMtEHyy+k6zLC3LiUTcBF5GJZxAXWnsiZUBmGXhjIlFXIX' +
            'E6t1qpCdsCZwpjdtgIWiSclERPHwuZfTQgFn2usAw9rVpmQCLiIfvTveDRgNhTWhhAJrV7ch0ncD' +
            'XMQQOPl7QTZzCaQyyKNdH1ooRjjbBWQyl0Ayg7BLSTdXcBGDIOw0e2DhSCuaqalEWLtuWULg3W0Q' +
            'LBUMoaBKLdauPqVQZMVeEiYYHYAbo4YmX2eQR7uSCkUw2m0nTQe1Q4JNBkloIY6c6NMmHmYDUOXM' +
            'gkY2dQomg7B2yZW7CYHcqIwBqHJ0B0VDpxjWrtX2PiWgGzZHpff6nqbOxFUPLaoDmYBu2B0B0H6y' +
            'g6Jh4goVoMSd+RLIDbsjAFFDd1AkTLeJhSJpZ74EqoN2RwCihu6gaDTTELgAOduS9IBuNMYCRE01' +
            'Xd0jFO98hLcAdGNuirevC33/DqHo3/cIbwnkhtMUX+QGDFNi6yITWigKaHA7so7C8P5Ye90DAOvg' +
            'ocKdDMxEHbezWK96771azXKgqFKQ7khTioXk+bt1u9+GTYXaH8XWQRMzd+jMYwtQQ7vPpUKxGnu4' +
            'aZT/Dkd4sQXoxmAxyx7P528TzH/3l/77+ineDbNFTHuE58W4GK/fz+fzV43T6ZSfcoWXEc8vzwGi' +
            'EumGYSLtEZ4fzPrGGaqOd8O+pGopA0YGRcblxTe2BYsKFZ6RQmFflN7hCC/WB6b7HCpUeHoOCHxo' +
            'zf6P+jSAlUFxVIzuM+Ipyz7/oPAl8x0Q+JywpQG2Ls7hNF1q486aq793Pv5e4dfPBXh6EvcW5Mr/' +
            'NIAjFJELIphTzOgEUUNFvAUZ2mJ+xh0+rhkRcT6shKKUHEuSChWe4ULRNW6TSH4awPi4RkMEFpEA' +
            '90kqVHi2IQ/v5bVeNMsMoUCPWH0wkjetDPBGuc9MK2YW/RP4A43YlmsKZW5kc3RyZWFtCmVuZG9i' +
            'agp4cmVmCjAgMjEKMDAwMDAwMDAwMCA2NTUzNSBmIAowMDAwMDAwOTY2IDAwMDAwIG4gCjAwMDAw' +
            'MjY2MjEgMDAwMDAgbiAKMDAwMDAwMTAxMSAwMDAwMCBuIAowMDAwMDE3MjYxIDAwMDAwIG4gCjAw' +
            'MDAwMDA3ODAgMDAwMDAgbiAKMDAwMDAwMDAxNSAwMDAwMCBuIAowMDAwMDI2NDg3IDAwMDAwIG4g' +
            'CjAwMDAwMjY2NzIgMDAwMDAgbiAKMDAwMDAyNzIyNiAwMDAwMCBuIAowMDAwMDAxMTYxIDAwMDAw' +
            'IG4gCjAwMDAwMDE0MDIgMDAwMDAgbiAKMDAwMDAyNzUxMiAwMDAwMCBuIAowMDAwMDI3NTk1IDAw' +
            'MDAwIG4gCjAwMDAwMjc5NzUgMDAwMDAgbiAKMDAwMDAxNzM5MSAwMDAwMCBuIAowMDAwMDE3NjM5' +
            'IDAwMDAwIG4gCjAwMDAwMjg0NjUgMDAwMDAgbiAKMDAwMDAyODU0NyAwMDAwMCBuIAowMDAwMDI4' +
            'OTE5IDAwMDAwIG4gCjAwMDAwMjkzNzUgMDAwMDAgbiAKdHJhaWxlcgo8PC9JRCBbPDMwN2VmMGI5' +
            'Y2FmMGMzMjE5NzE0YzAwNDBkOTE2NWEwPjwzMDdlZjBiOWNhZjBjMzIxOTcxNGMwMDQwZDkxNjVh' +
            'MD5dL0luZm8gMyAwIFIvUm9vdCAxIDAgUi9TaXplIDIxPj4KJWlUZXh0LUNvcmUtNy4yLjAKc3Rh' +
            'cnR4cmVmCjMwMzgzCiUlRU9GCg==';
        exit(base64);
    end;
    // var
    //     myInt: Integer;
}