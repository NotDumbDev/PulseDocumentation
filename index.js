function switchTab(tabId) {
    document.querySelectorAll(".tab-content").forEach(tab => tab.classList.remove("active"));
    document.querySelectorAll(".tab-button").forEach(btn => btn.classList.remove("active"));
    document.getElementById(tabId).classList.add("active");
    document.querySelector(`[data-tab="${tabId}"]`).classList.add("active");
}

document.addEventListener("DOMContentLoaded", () => {
    const searchInput = document.getElementById("searchInput");

if (searchInput) {
    searchInput.addEventListener("keydown", event => {
      if (event.key === "Enter") {
        const query = searchInput.value.toLowerCase();
        const methods = document.querySelectorAll(".method-name");

        for (const method of methods) {
          const text = method.textContent.toLowerCase();

          if (text.toLowerCase().includes(query)) {
            method.scrollIntoView({ behavior: "smooth", block: "center" });
            method.classList.add("highlight");

            setTimeout(() => method.classList.remove("highlight"), 800);
            break;
          }
        }
      }
    });
  }

    document.querySelectorAll('a[data-target-tab]').forEach(link => {
        link.addEventListener("click", function (e) {
            e.preventDefault();

            const tabId = this.getAttribute("data-target-tab");
            const anchor = this.getAttribute("href");

            switchTab(tabId);

            setTimeout(() => {
                const target = document.querySelector(anchor);
                if (target) {
                  target.scrollIntoView({ behavior: "smooth", block: "center" });
                  target.classList.add("highlight");

                  setTimeout(() => target.classList.remove("highlight"), 800);
                }
            }, 50);
        });
    });
});
