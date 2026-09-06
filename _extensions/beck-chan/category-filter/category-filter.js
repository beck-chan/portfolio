(() => {
  const SELECTOR = ".category-filter__select";
  const CATEGORY_SELECTOR = ".quarto-listing-category .category";

  const categoryLabel = (el) => {
    const clone = el.cloneNode(true);
    clone.querySelectorAll(".quarto-category-count").forEach((count) => {
      count.remove();
    });
    return clone.textContent.replace(/\s+/g, " ").trim();
  };

  const categoryCount = (el) => {
    const countEl = el.querySelector(".quarto-category-count");
    if (!countEl) {
      return "";
    }
    return countEl.textContent.replace(/[()\s]/g, "").trim();
  };

  const populateSelect = (select) => {
    const categories = window.document.querySelectorAll(CATEGORY_SELECTOR);
    if (!categories.length) {
      return false;
    }

    select.replaceChildren();

    for (const categoryEl of categories) {
      const option = window.document.createElement("option");
      const dataCategory = categoryEl.getAttribute("data-category") ?? "";
      const label = categoryLabel(categoryEl) || "All";
      const count = categoryCount(categoryEl);

      option.value = dataCategory;
      option.textContent = count ? `${label} (${count})` : label;
      if (categoryEl.classList.contains("active")) {
        option.selected = true;
      }
      select.appendChild(option);
    }

    return true;
  };

  const syncSelectFromActive = (select) => {
    const active = window.document.querySelector(
      `${CATEGORY_SELECTOR}.active`
    );
    const value = active ? active.getAttribute("data-category") ?? "" : "";
    if (select.value !== value) {
      select.value = value;
    }
  };

  const bindSelect = (select) => {
    select.addEventListener("change", () => {
      if (typeof window.quartoListingCategory === "function") {
        window.quartoListingCategory(select.value);
      }
    });
  };

  const watchMarginCategories = (select) => {
    const container = window.document.querySelector(".quarto-listing-category");
    if (!container || typeof MutationObserver === "undefined") {
      return;
    }

    const observer = new MutationObserver(() => {
      syncSelectFromActive(select);
    });
    observer.observe(container, {
      attributes: true,
      attributeFilter: ["class"],
      subtree: true,
    });
  };

  window.document.addEventListener("DOMContentLoaded", () => {
    const selects = window.document.querySelectorAll(SELECTOR);
    if (!selects.length) {
      return;
    }

    for (const select of selects) {
      populateSelect(select);
      bindSelect(select);
      syncSelectFromActive(select);
      watchMarginCategories(select);
    }

    // Listing category handlers attach on DOMContentLoaded; re-sync after
    // hash-based activation runs in quarto-listing.js.
    window.setTimeout(() => {
      for (const select of selects) {
        if (!select.options.length || select.options.length === 1) {
          populateSelect(select);
        }
        syncSelectFromActive(select);
      }
    }, 0);
  });
})();
