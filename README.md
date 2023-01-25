# ForNav.Demo.PrintPdf
Sample code for printing an existing PDF in Business Central using ForNAV Direct Print.

## Introduction
This example will show you how to send a PDF document to a printer without any user interaction.

We have created a sample shipping PDF from DHL Express and will show you how to print it.
The shipping document is something you would normally have in a BLOB field in your database, or 
you can get it from the API provided by the shipping provider. In that case, it would be the
result of an HTTP call.

In order to keep this demo as simple as possible, the PDF is stored in a Base64 string in the code.
You can also find a copy of the document in the documents folder. 
This file is only there to let you see the document. It is not used in the code. 
Instead, we use the Base64 encoded version of it.
