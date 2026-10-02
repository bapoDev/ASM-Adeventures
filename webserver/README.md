# Assembly Web Server

Responds to GET and POST with a default page, will be updated to support custom pages.

## Compile

```bash
as -o webserver.o webserver.asm
ld -o webserver webserver.o
```

## Run

Simply execute `sudo webserver`, sudo is required as I used the 80 port, you can change that to 8080 to circumvent that restriction.
