import cheerio from "cheerio";
import request from "request";
import excel from "excel4node";

const url = "https://www.russiangost.com/m-127-gost.aspx?section=5234";

request(url, async (error, response, html) => {
  if (!error && response.statusCode == 200) {
    const $ = cheerio.load(html); // load HTML

    const result = handleCrawl($);
    const totalPage = $(
      "#ctl00_PageContent_pnlContent > div:nth-child(6) > ul > li:nth-last-child(2)"
    )
      .find("a")
      .text();
    let i = 2;

    while (i <= totalPage) {
      const html = await doRequest(`${url}&pagenum=${i}`);
      const $ = cheerio.load(html); // load HTML
      console.log(handleCrawl($));
      result.push(...handleCrawl($));
      i++;
    }

    console.log(result.length);
    const workbook = new excel.Workbook();
    const worksheet = workbook.addWorksheet("TabName");

    worksheet.cell(1, 1).string("Name");
    worksheet.cell(1, 2).string("Description");
    worksheet.cell(1, 3).string("Price");
    let count = 2;

    result.map((data) => {
      worksheet.cell(count, 1).string(data.title);
      worksheet.cell(count, 2).string(data.body);
      worksheet.cell(count, 3).string(data.price);

      count++;
    });

    workbook.write("Result.xlsx");
  } else {
    console.log(error);
  }
});

function doRequest(url) {
  return new Promise(function (resolve, reject) {
    request(url, function (error, res, body) {
      if (!error && res.statusCode == 200) {
        resolve(body);
      } else {
        reject(error);
      }
    });
  });
}

function handleCrawl($) {
  const result = [];
  $(
    "#ctl00_PageContent_pnlContent > div:nth-child(7) > table > tbody > tr"
  ).each((_, tr) => {
    $(tr)
      .find("td")
      .each((_, td) => {
        const data = {};
        $(td)
          .find("tr")
          .each((_, tr) => {
            const a = $(tr).find("a");

            const text = a.text();
            const type = a.attr("itemtype");

            if (type === "name") {
              data["title"] = text;
            }

            if (type === "Summary") {
              data["body"] = text;
            }

            const price = $(tr).find("meta").attr("content");
            data["price"] = price || "";
          });

        if (Object.keys(data).length !== 0) result.push(data);
      });
  });

  return result;
}
