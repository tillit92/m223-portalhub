# 10: Fehlerseiten auf Deutsch

**What to build:** The pages people see when something goes wrong (not found, rejected change, server error, bad request, browser too old) are in German, in the app's look, and say what to do next, instead of the English Rails defaults.

**Blocked by:** None (can start immediately)

**Status:** done

- [x] 404, 422, 500, 400 and the "browser too old" page are German, dark, with the green ring and a Rick and Morty tone
- [x] Pages that can be left offer a way back to the overview; the "browser too old" page names the minimum versions
- [x] No English Rails default text is left on any of them
- [x] An unknown Portal shows the German 404 page
- [x] A browser below the minimum versions gets the German page
- [x] Integration tests cover the served pages and the two situations above
