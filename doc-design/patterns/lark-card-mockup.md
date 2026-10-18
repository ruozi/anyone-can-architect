# Lark Card Mockup

## 1 When to Use

Present the appearance and interactions of Lark (Feishu) cards in design docs
Use HTML to simulate real scenarios and display card mockups to guide card JSON implementation

## 2 Overall Presentation Principles

Cover all user-visible scenarios and states, and show a complete [card mockup](../../CONTEXT.md#card-mockup) for each state
Make card mockups as close as possible to the visual appearance and interactions in actual scenarios
Use card mockups to convey information as fully as possible, and omit explanatory text for information that a card mockup can convey
Use specific example values that match the current scenario and state for dynamic content, with reasonable compromises or additional card mockups for extreme cases

Address private chat text to the recipient, and make clear who needs to act in group chat text
Use a friendly tone, consider the recipient's feelings, and use business-relevant language to explain the facts and what the user needs to do

## 3 Overall Card Mockup Presentation

### 3.1 Canvas

Use `class="card-mockup"` on the root node
Adapt the card width to the available width of its host and use the available space fully
Determine the minimum supported width based on the usage environment, and keep the layout fully usable at that width
Use a white background, a 1px `#dee0e3` border, an 8px corner radius, 14px body text, and a line height of 1.6

### 3.2 Long Content and Pagination

**Scenarios Without Pagination**

The full content meets both of the following [capacity limits](../../SSOT.md#7-platforms-and-tools)
- The card message body does not exceed 30 KB
- The total number of elements and components does not exceed 200

Confirmation cards
- If the confirmation details exceed capacity, keep only the fields that identify each object
- If the content still exceeds capacity after reducing fields, show the first few items that fit and the last item, with an ellipsis in between
- If not all items are listed, state the total at the end

<div class="card-mockup" style="width:100%;box-sizing:border-box;min-width:0;border:1px solid #dee0e3;border-radius:8px;overflow:hidden;background:#fff;color:#1f2329;font-family:system-ui,sans-serif;font-size:14px;font-weight:400;line-height:1.6">
<div class="card-header theme-blue" style="padding:8px 12px;background:#e8f1ff;color:#1f5bd6">
<div class="card-title" style="font-size:14px;font-weight:600;line-height:22px;color:inherit">Product data import · ⏳ Awaiting confirmation</div>
</div>
<div style="padding:10px 12px">
<div class="field-row" style="display:flex;gap:12px;margin:4px 0"><div class="field-label text-grey" style="flex:0 0 64px;font-size:14px;line-height:22px;color:#646a73">File</div><div class="field-value" style="flex:1;min-width:0;overflow-wrap:anywhere">Chestnut Store Product Data.xlsx</div></div>
<hr style="border:0;border-top:1px solid #dee0e3;margin:12px 0">
<div style="display:grid;grid-template-columns:2.5em 6em minmax(0,1fr);column-gap:10px;row-gap:6px;align-items:start">
<div style="font-weight:700;text-align:right">No.</div><div style="font-weight:700">Product code</div><div style="font-weight:700">Product name</div>
<div style="text-align:right">1</div><div><code>A3K9F2</code></div><div style="overflow-wrap:anywhere">Chestnut gift box</div>
<div style="text-align:right">2</div><div><code>B7M2Q8</code></div><div style="overflow-wrap:anywhere">Hazelnut gift box</div>
<div style="text-align:right">3</div><div><code>C4P6R1</code></div><div style="overflow-wrap:anywhere">Pistachio gift box</div>
<div class="text-grey" style="grid-column:1/-1;color:#646a73">……</div>
<div style="grid-column:1/-1;height:14px" aria-hidden="true"></div>
<div style="text-align:right">200</div><div><code>Z8N5T3</code></div><div style="overflow-wrap:anywhere">Cashew gift box</div>
</div>
<div class="text-grey" style="margin:4px 0;color:#646a73">200 product records in total</div>
<hr style="border:0;border-top:1px solid #dee0e3;margin:12px 0">
<div class="button-area" style="display:flex;flex-wrap:wrap;gap:8px;margin-top:6px">
<span class="card-button button-primary button-callback" data-action="confirm_import" data-object-key="current-object" style="display:inline-block;padding:4px 12px;border:1px solid #94b4ff;border-radius:6px;background:#fff;color:#1456f0">✅ Confirm import</span>
<span class="card-button button-default button-callback" data-action="cancel" data-object-key="current-object" style="display:inline-block;padding:4px 12px;border:1px solid #dee0e3;border-radius:6px;background:#fff;color:#1f2329">🚫 Cancel</span>
</div>
</div>
</div>

Form cards
- If the content exceeds capacity, keep the required fields and reduce optional explanations
- If the required fields still exceed capacity, adjust the form completion workflow

<div class="card-mockup" style="width:100%;box-sizing:border-box;min-width:0;border:1px solid #dee0e3;border-radius:8px;overflow:hidden;background:#fff;color:#1f2329;font-family:system-ui,sans-serif;font-size:14px;font-weight:400;line-height:1.6">
<div class="card-header theme-blue" style="padding:8px 12px;background:#e8f1ff;color:#1f5bd6">
<div class="card-title" style="font-size:14px;font-weight:600;line-height:22px;color:inherit">Follow-up task · ⏳ Awaiting input</div>
</div>
<form name="form_followup_task" style="padding:10px 12px">
<div class="form-label" data-field-name="task_name" style="font-weight:700;margin:6px 0 4px">Task name <span class="text-red" style="color:#c02a26">*</span></div>
<div class="card-input input-single is-required" data-field-name="task_name" style="padding:6px 8px;border:1px solid #dee0e3;border-radius:6px" data-value="Follow up with customers who left negative reviews of the chestnut gift box">Follow up with customers who left negative reviews of the chestnut gift box</div>
<div class="form-label" data-field-name="owner" style="font-weight:700;margin:10px 0 4px">Assignee <span class="text-red" style="color:#c02a26">*</span></div>
<div class="card-select select-person-single is-required" data-field-name="owner" style="padding:6px 8px;border:1px solid #dee0e3;border-radius:6px;color:#8f959e" data-options-key="assignees"><span class="is-placeholder">Select an assignee</span> ▾</div>
<hr style="border:0;border-top:1px solid #dee0e3;margin:12px 0">
<div class="button-area" style="display:flex;flex-wrap:wrap;gap:8px;margin-top:6px">
<span class="card-button button-primary button-callback form-submit" data-field-name="submit" data-action="create_task" data-object-key="current-object" style="display:inline-block;padding:4px 12px;border:1px solid #94b4ff;border-radius:6px;background:#fff;color:#1456f0">✅ Create task</span>
<span class="card-button button-default button-callback form-cancel" data-field-name="cancel" data-action="cancel" data-object-key="current-object" style="display:inline-block;padding:4px 12px;border:1px solid #dee0e3;border-radius:6px;background:#fff;color:#1f2329">🚫 Cancel</span>
</div>
</form>
</div>

Extremely long content
- Summarize noncritical content and display it on a single card within capacity
- Keep the information needed to identify the object, determine its state, and take action in the summary

<div class="card-mockup" style="width:100%;box-sizing:border-box;min-width:0;border:1px solid #dee0e3;border-radius:8px;overflow:hidden;background:#fff;color:#1f2329;font-family:system-ui,sans-serif;font-size:14px;font-weight:400;line-height:1.6">
<div class="card-header theme-green" style="padding:8px 12px;background:#eaf9e6;color:#237804">
<div class="card-title" style="font-size:14px;font-weight:600;line-height:22px;color:inherit">After-sales communication · ✅ Summarized</div>
</div>
<div style="padding:10px 12px">
<div class="field-row" style="display:flex;gap:12px;margin:4px 0"><div class="field-label text-grey" style="flex:0 0 64px;font-size:14px;line-height:22px;color:#646a73">Order</div><div class="field-value" style="flex:1;min-width:0;overflow-wrap:anywhere"><code>A3K9F2</code></div></div>
<div style="font-weight:700;margin-top:8px">📝 Communication summary</div>
<div style="margin:4px 0">The customer received a damaged gift box and requested a replacement</div>
<div style="margin:4px 0">A free replacement was agreed upon, and the customer does not need to return the original gift box</div>
<div style="font-weight:700;margin-top:8px">⚡ Next step</div>
<div style="margin:4px 0">Ship the replacement gift box by 18:00 today</div>
<hr style="border:0;border-top:1px solid #dee0e3;margin:12px 0">
<div class="button-area" style="display:flex;flex-wrap:wrap;gap:8px">
<a class="card-button button-default button-open-url" href="https://example.com/orders/A3K9F2/communications" style="display:inline-block;padding:4px 12px;border:1px solid #dee0e3;border-radius:6px;color:#1f2329;text-decoration:none">📜 View full communication history</a>
</div>
</div>
</div>

**Pagination Methods**

Changing pages in a private chat updates the original card
Changing pages in a group chat updates the original card by default, and members who can see the card share the current page and can change pages
When users need to browse independently, send the user who clicked a browsing card in a private chat that references the same results, and keep the original group chat card unchanged
The private chat browsing card provides only browsing and pagination actions, while business confirmation, cancellation, and submission remain on the original card
Changing pages does not change the ownership of the original card or permissions for business actions
Specify the pagination method used by the group chat card in the detailed design

Keep the title and total on every page
Changing pages switches only the details
When a nested list or an extremely long record spans pages, keep its parent object's identifier and title on continuation pages
When task progress changes require a refresh of paginated content, preserve the reading position of the first displayed unit on the current page
Follow [card mapping](../../skills/references/lark-card-mapping.md#32-long-content-and-pagination) for repagination and positioning

Use a divider at the bottom of the page to separate a dedicated pagination area
Include the currently displayed range, total, and pagination buttons in the pagination area
Show "⬅️ Previous page" on every page except the first
Show "➡️ Next page" when more content follows

<div class="card-mockup" style="width:100%;box-sizing:border-box;min-width:0;border:1px solid #dee0e3;border-radius:8px;overflow:hidden;background:#fff;color:#1f2329;font-family:system-ui,sans-serif;font-size:14px;font-weight:400;line-height:1.6">
<div class="card-header theme-blue" style="padding:8px 12px;background:#e8f1ff;color:#1f5bd6">
<div class="card-title" style="font-size:14px;font-weight:600;line-height:22px;color:inherit">Product data lookup</div>
</div>
<div style="padding:10px 12px">
<div class="outlined-block" style="border:1px solid #dfe1e3;border-radius:8px;padding:8px 12px;margin:8px 0">
<div class="text-heading" style="font-size:16px;font-weight:700">📦 Nut gift box collection (continued)</div>
<div style="display:grid;grid-template-columns:2.5em 6em minmax(0,1fr);column-gap:10px;row-gap:6px;align-items:start;margin-top:8px">
<div style="font-weight:700;text-align:right">No.</div><div style="font-weight:700">Product code</div><div style="font-weight:700">Product name</div>
<div style="text-align:right">27</div><div><code>P00027</code></div><div style="overflow-wrap:anywhere">Chestnut gift box 1kg</div>
<div style="text-align:right">28</div><div><code>P00028</code></div><div style="overflow-wrap:anywhere">Hazelnut gift box 1kg</div>
<div style="text-align:right">29</div><div><code>P00029</code></div><div style="overflow-wrap:anywhere">Pistachio gift box 1kg</div>
</div>
</div>
<div class="outlined-block" style="border:1px solid #dfe1e3;border-radius:8px;padding:8px 12px;margin:8px 0">
<div class="text-heading" style="font-size:16px;font-weight:700">📦 Dried fruit gift box collection</div>
<div style="display:grid;grid-template-columns:2.5em 6em minmax(0,1fr);column-gap:10px;row-gap:6px;align-items:start;margin-top:8px">
<div style="font-weight:700;text-align:right">No.</div><div style="font-weight:700">Product code</div><div style="font-weight:700">Product name</div>
<div style="text-align:right">30</div><div><code>P00030</code></div><div style="overflow-wrap:anywhere">Raisin gift box 250g</div>
<div style="text-align:right">31</div><div><code>P00031</code></div><div style="overflow-wrap:anywhere">Cranberry gift box 250g</div>
</div>
</div>
<hr style="border:0;border-top:1px solid #dee0e3;margin:12px 0">
<div style="display:flex;flex-direction:column;gap:6px">
<div class="text-grey" style="font-size:12px;color:#646a73">Records 27–31 of 200</div>
<div class="button-area" style="display:flex;flex-wrap:wrap;gap:8px">
<span class="card-button button-default button-callback" data-action="previous_page" data-object-key="current-object" style="display:inline-block;padding:4px 12px;border:1px solid #dee0e3;border-radius:6px;background:#fff;color:#1f2329">⬅️ Previous page</span>
<span class="card-button button-default button-callback" data-action="next_page" data-object-key="current-object" style="display:inline-block;padding:4px 12px;border:1px solid #dee0e3;border-radius:6px;background:#fff;color:#1f2329">➡️ Next page</span>
</div>
</div>
</div>
</div>

## 4 Title Bar

Use `card-header` for the title bar and specify exactly one theme class from the table
Set vertical padding to 8px and horizontal padding to 12px
Use `card-title` for the main title, which is required and unique, with a font size of 14px, a font weight of 600, a line height of 22px, and text color inherited from the title bar
Use `card-subtitle` for the optional subtitle, with at most one subtitle, a font size of 14px, regular weight, a line height of 22px, and text color inherited from the title bar

| Theme class | Background color | Text color | Standard meaning |
| --- | --- | --- | --- |
| `theme-default` | `ffffff` | `1f2329` | Use when a title without color is explicitly required |
| `theme-blue` | `e8f1ff` | `1f5bd6` | Standard cards: details, queries and no matching results, data entry, selection, normal confirmation, processing and progress notifications |
| `theme-green` | `eaf9e6` | `237804` | Success, completion |
| `theme-orange` | `fff1e6` | `d46b08` | Warnings, time alerts, additional information or clarification required to continue |
| `theme-red` | `fdecec` | `d83931` | Failure, error, overdue, object searched for by a specific identifier does not exist |
| `theme-grey` | `646a73` | `ffffff` | Invalid, expired, revoked, canceled, or confirmation of termination |

Example:

<div class="card-mockup" style="width:100%;box-sizing:border-box;min-width:0;border:1px solid #dee0e3;border-radius:8px;overflow:hidden;background:#fff;color:#1f2329;font-family:system-ui,sans-serif;font-size:14px;line-height:1.6">
<div class="card-header theme-default" style="padding:8px 12px;background:#ffffff;color:#1f2329">
<div class="card-title" style="font-size:14px;font-weight:600;line-height:22px;color:inherit">Product information query</div>
</div>
</div>

<div class="card-mockup" style="width:100%;box-sizing:border-box;min-width:0;border:1px solid #dee0e3;border-radius:8px;overflow:hidden;background:#fff;color:#1f2329;font-family:system-ui,sans-serif;font-size:14px;line-height:1.6">
<div class="card-header theme-blue" style="padding:8px 12px;background:#e8f1ff;color:#1f5bd6">
<div class="card-title" style="font-size:14px;font-weight:600;line-height:22px;color:inherit">Order details · ⏳ Awaiting shipment</div>
<div class="card-subtitle" style="font-size:14px;font-weight:400;line-height:22px;color:inherit">Chestnut gift box · 3 items total</div>
</div>
</div>

<div class="card-mockup" style="width:100%;box-sizing:border-box;min-width:0;border:1px solid #dee0e3;border-radius:8px;overflow:hidden;background:#fff;color:#1f2329;font-family:system-ui,sans-serif;font-size:14px;line-height:1.6">
<div class="card-header theme-green" style="padding:8px 12px;background:#eaf9e6;color:#237804">
<div class="card-title" style="font-size:14px;font-weight:600;line-height:22px;color:inherit">Data import · ✅ Completed</div>
</div>
</div>

<div class="card-mockup" style="width:100%;box-sizing:border-box;min-width:0;border:1px solid #dee0e3;border-radius:8px;overflow:hidden;background:#fff;color:#1f2329;font-family:system-ui,sans-serif;font-size:14px;line-height:1.6">
<div class="card-header theme-orange" style="padding:8px 12px;background:#fff1e6;color:#d46b08">
<div class="card-title" style="font-size:14px;font-weight:600;line-height:22px;color:inherit">Data import · ⚠️ Partially failed</div>
</div>
</div>

<div class="card-mockup" style="width:100%;box-sizing:border-box;min-width:0;border:1px solid #dee0e3;border-radius:8px;overflow:hidden;background:#fff;color:#1f2329;font-family:system-ui,sans-serif;font-size:14px;line-height:1.6">
<div class="card-header theme-red" style="padding:8px 12px;background:#fdecec;color:#d83931">
<div class="card-title" style="font-size:14px;font-weight:600;line-height:22px;color:inherit">Data import · ❌ Failed</div>
</div>
</div>

<div class="card-mockup" style="width:100%;box-sizing:border-box;min-width:0;border:1px solid #dee0e3;border-radius:8px;overflow:hidden;background:#fff;color:#1f2329;font-family:system-ui,sans-serif;font-size:14px;line-height:1.6">
<div class="card-header theme-blue" style="padding:8px 12px;background:#e8f1ff;color:#1f5bd6">
<div class="card-title" style="font-size:14px;font-weight:600;line-height:22px;color:inherit">Product query · No matching results</div>
</div>
</div>

<div class="card-mockup" style="width:100%;box-sizing:border-box;min-width:0;border:1px solid #dee0e3;border-radius:8px;overflow:hidden;background:#fff;color:#1f2329;font-family:system-ui,sans-serif;font-size:14px;line-height:1.6">
<div class="card-header theme-grey" style="padding:8px 12px;background:#646a73;color:#ffffff">
<div class="card-title" style="font-size:14px;font-weight:600;line-height:22px;color:inherit">Data import · Canceled</div>
</div>
</div>

## 5 Layout

### 5.1 Field Row

Use a description list with separate columns for labels and values
Use `field-row` for field rows, `field-label` for labels, and `field-value` for values
Set the label column to a fixed width of 64px and the column gap to 12px, left-align the value column, wrap long content within the column, and do not use spaces for alignment
Use 14px for both labels and values, with `#646a73` for label text and `#1f2329` for value text

<div class="card-mockup" style="width:100%;box-sizing:border-box;min-width:0;border:1px solid #dee0e3;border-radius:8px;overflow:hidden;background:#fff;color:#1f2329;font-family:system-ui,sans-serif;font-size:14px;font-weight:400;line-height:1.6">
<div style="padding:10px 12px">
<div class="field-row" style="display:flex;gap:12px;margin:4px 0"><div class="field-label text-grey" style="flex:0 0 64px;font-size:14px;line-height:22px;color:#646a73">Status</div><div class="field-value" style="flex:1;min-width:0;overflow-wrap:anywhere;color:#1f2329">⏳ In progress</div></div>
<div class="field-row" style="display:flex;gap:12px;margin:4px 0"><div class="field-label text-grey" style="flex:0 0 64px;font-size:14px;line-height:22px;color:#646a73">Expected time</div><div class="field-value" style="flex:1;min-width:0;overflow-wrap:anywhere;color:#1f2329">Tomorrow 18:30</div></div>
<div class="field-row" style="display:flex;gap:12px;margin:4px 0"><div class="field-label text-grey" style="flex:0 0 64px;font-size:14px;line-height:22px;color:#646a73">Delivery address</div><div class="field-value" style="flex:1;min-width:0;overflow-wrap:anywhere;color:#1f2329">Room 1203, Unit 2, Building 3, 88 Zhangjiang Road, Pudong New Area, Shanghai</div></div>
</div>
</div>

### 5.2 Divider

Separate different information blocks with a divider on its own line
Do not add dividers between objects already separated by outline boxes
Separate a standalone action area from the content above it with a divider, but do not add a divider before inline buttons
Use a 1px solid `#dee0e3` divider with 12px spacing above and below

<div class="card-mockup" style="width:100%;box-sizing:border-box;min-width:0;border:1px solid #dee0e3;border-radius:8px;overflow:hidden;background:#fff;color:#1f2329;font-family:system-ui,sans-serif;font-size:14px;font-weight:400;line-height:1.6">
<div class="card-header theme-blue" style="padding:8px 12px;background:#e8f1ff;color:#1f5bd6">
<div class="card-title" style="font-size:14px;font-weight:600;line-height:22px;color:inherit">Product data import · ⏳ Awaiting confirmation</div>
</div>
<div style="padding:10px 12px">
<div>Chestnut Store Product Data.xlsx</div>
<div>200 product records total</div>
<hr style="border:0;border-top:1px solid #dee0e3;margin:12px 0">
<div class="button-area" style="display:flex;flex-wrap:wrap;gap:8px">
<span class="card-button button-primary button-callback" data-action="confirm_import" data-object-key="current-object" style="display:inline-block;padding:4px 12px;border:1px solid #94b4ff;border-radius:6px;background:#fff;color:#1456f0">✅ Confirm import</span>
<span class="card-button button-default button-callback" data-action="cancel" data-object-key="current-object" style="display:inline-block;padding:4px 12px;border:1px solid #dee0e3;border-radius:6px;background:#fff;color:#1f2329">🚫 Cancel</span>
</div>
</div>
</div>

### 5.3 Outline Box

When a card contains multiple objects of the same type and each object needs to display multiple attributes or separate actions, use one outline box per object
Use `outlined-block` for outline boxes
Use a 1px solid `#dfe1e3` border, an 8px corner radius, 8px vertical padding, and 12px horizontal padding
Set the gap between adjacent outline boxes to 8px
Place the details button at the far right inside the box, vertically centered relative to the entire content block on the left

<div class="card-mockup" style="width:100%;box-sizing:border-box;min-width:0;border:1px solid #dee0e3;border-radius:8px;overflow:hidden;background:#fff;color:#1f2329;font-family:system-ui,sans-serif;font-size:14px;font-weight:400;line-height:1.6">
<div style="padding:10px 12px">
<div style="display:flex;flex-direction:column;gap:8px">
<div class="outlined-block" style="display:flex;align-items:center;gap:8px;border:1px solid #dfe1e3;border-radius:8px;padding:8px 12px">
<div style="flex:1;min-width:0;overflow-wrap:anywhere">
<div style="font-weight:700">🧩 Subtask 1 · Design the login page</div>
<div class="field-row" style="display:flex;gap:12px;margin:4px 0"><div class="field-label text-grey" style="flex:0 0 64px;font-size:14px;line-height:22px;color:#646a73">Expected time</div><div class="field-value" style="flex:1;min-width:0;color:#1f2329">Tomorrow 18:30</div></div>
</div>
<span class="card-button button-default button-callback" data-action="view_details" data-object-key="current-object" style="flex:0 0 auto;white-space:nowrap;padding:4px 12px;border:1px solid #dee0e3;border-radius:6px;background:#fff;color:#1f2329">🔎 Details</span>
</div>
<div class="outlined-block" style="display:flex;align-items:center;gap:8px;border:1px solid #dfe1e3;border-radius:8px;padding:8px 12px">
<div style="flex:1;min-width:0;overflow-wrap:anywhere">
<div style="font-weight:700">🧩 Subtask 2 · Test API integration</div>
<div class="field-row" style="display:flex;gap:12px;margin:4px 0"><div class="field-label text-grey" style="flex:0 0 64px;font-size:14px;line-height:22px;color:#646a73">Expected time</div><div class="field-value" style="flex:1;min-width:0;color:#1f2329">Friday 18:30</div></div>
</div>
<span class="card-button button-default button-callback" data-action="view_details" data-object-key="current-object" style="flex:0 0 auto;white-space:nowrap;padding:4px 12px;border:1px solid #dee0e3;border-radius:6px;background:#fff;color:#1f2329">🔎 Details</span>
</div>
</div>
</div>
</div>

### 5.4 Gray Background Block

Place content that explains what the current object belongs to in a gray background block, such as the parent task of a subtask
Use `grey-block` for gray background blocks
Use a `#f5f6f7` background, a 4px corner radius, 8px vertical padding, and 12px horizontal padding

<div class="card-mockup" style="width:100%;box-sizing:border-box;min-width:0;border:1px solid #dee0e3;border-radius:8px;overflow:hidden;background:#fff;color:#1f2329;font-family:system-ui,sans-serif;font-size:14px;font-weight:400;line-height:1.6">
<div style="padding:10px 12px">
<div class="grey-block" style="background:#f5f6f7;border-radius:4px;padding:8px 12px;margin:8px 0">
<div style="font-weight:700">🗂 Parent task</div>
<div class="field-row" style="display:flex;gap:12px;margin:4px 0"><div class="field-label text-grey" style="flex:0 0 64px;font-size:14px;line-height:22px;color:#646a73">Task</div><div class="field-value" style="flex:1;min-width:0;color:#1f2329">Product launch event preparation <code>a3Kf9X</code></div></div>
</div>
</div>
</div>

### 5.5 Action Block

Use an action block after the relevant content when you need to highlight an action the user should take
Use `action-block` for action blocks and select colors based on the title theme class of the containing card
Use a 4px vertical line on the left of the block and select the background and line colors from the table below
Use a 4px corner radius, 8px vertical padding, and 12px horizontal padding
Use `#1f2329` for the block title color and `font-weight:700` for its font weight

| Theme class | Vertical line | Background color |
| --- | --- | --- |
| `theme-orange` | `#ff811a` | `#fff3e5` |
| `theme-red` | `#ff7570` | `#fef0f0` |
| `theme-blue` | `#7aa2ff` | `#f0f4ff` |
| `theme-green` | `#35bd4b` | `#e4fae1` |
| `theme-default` | `#7aa2ff` | `#f0f4ff` |
| `theme-grey` | `#7aa2ff` | `#f0f4ff` |

<div class="card-mockup" style="width:100%;box-sizing:border-box;min-width:0;border:1px solid #dee0e3;border-radius:8px;overflow:hidden;background:#fff;color:#1f2329;font-family:system-ui,sans-serif;font-size:14px;font-weight:400;line-height:1.6">
<div class="card-header theme-orange" style="padding:8px 12px;background:#fff1e6;color:#d46b08">
<div class="card-title" style="font-size:14px;font-weight:600;line-height:22px;color:inherit">⏰ 1 hour until the committed time</div>
</div>
<div style="padding:10px 12px">
<div style="font-weight:700">Design the login page <code>b7Xy2Z</code></div>
<div class="action-block" style="border-left:4px solid #ff811a;border-radius:4px;background:#fff3e5;padding:8px 12px;margin:8px 0">
<div style="font-weight:700">⚡ What to do now</div>
<div>If you cannot finish on time, reply to this message with a new estimated completion time</div>
</div>
</div>
</div>

### 5.6 Collapse

Collapse noncritical information as needed, keeping summaries, key statuses, and information required for actions outside the collapsed area
Specify the collapsed content and its count in the title line
Use `<details>` in the mockup, collapsed by default

<div class="card-mockup" style="width:100%;box-sizing:border-box;min-width:0;border:1px solid #dee0e3;border-radius:8px;overflow:hidden;background:#fff;color:#1f2329;font-family:system-ui,sans-serif;font-size:14px;font-weight:400;line-height:1.6">
<div style="padding:10px 12px">
<details><summary style="font-weight:700">📜 History · 3 entries</summary><div style="margin-top:6px">9/28 18:30 John Smith adjusted the committed time</div><div>9/28 16:20 Jane Brown added delivery requirements</div><div>9/28 14:00 John Smith started working on the task</div></details>
</div>
</div>

### 5.7 Table Layout

Use `table-layout` for the table container, `table-header` for the header, and `table-row` for record rows
Use the container's `--table-columns` column width definition for both the header and record rows, with an 8px column gap
Place one record per row, align the same field by column, and left-align content columns
Use bold text for the header, place the action column at the far right, center the action header and buttons within the column, and vertically center buttons relative to the row content
Use a 1px solid `#dee0e3` divider at the bottom of the header and each record, with 8px padding above and below

<div class="card-mockup" style="width:100%;box-sizing:border-box;min-width:0;border:1px solid #dee0e3;border-radius:8px;overflow:hidden;background:#fff;color:#1f2329;font-family:system-ui,sans-serif;font-size:14px;font-weight:400;line-height:1.6">
<div class="card-header theme-blue" style="padding:8px 12px;background:#e8f1ff;color:#1f5bd6">
<div class="card-title" style="font-size:14px;font-weight:600;line-height:22px;color:inherit">Tag query</div>
</div>
<div class="table-layout" style="padding:10px 12px;--table-columns:minmax(0,1fr) 64px 84px">
<div class="table-header" style="display:grid;grid-template-columns:var(--table-columns);gap:8px;align-items:center;text-align:left;font-weight:700;padding:8px 0;border-bottom:1px solid #dee0e3"><span>Tag</span><span>App count</span><span style="text-align:center">Actions</span></div>
<div class="table-row" style="display:grid;grid-template-columns:var(--table-columns);gap:8px;align-items:center;text-align:left;padding:8px 0;border-bottom:1px solid #dee0e3"><span>Puzzle</span><span>2</span><span class="card-button button-default button-callback" data-action="view_record" data-object-key="current-object" style="justify-self:center;display:inline-block;padding:4px 12px;border:1px solid #dee0e3;border-radius:6px;background:#fff;color:#1f2329">🔎 View</span></div>
<div class="table-row" style="display:grid;grid-template-columns:var(--table-columns);gap:8px;align-items:center;text-align:left;padding:8px 0;border-bottom:1px solid #dee0e3"><span>Indie games</span><span>1</span><span class="card-button button-default button-callback" data-action="view_record" data-object-key="current-object" style="justify-self:center;display:inline-block;padding:4px 12px;border:1px solid #dee0e3;border-radius:6px;background:#fff;color:#1f2329">🔎 View</span></div>
</div>
</div>

### 5.8 Text Hierarchy Spacing

Set the gap between a body heading and its body text or first subheading to 4px
Set the gap between adjacent body paragraphs to 8px
Determine the gap between a new section heading and the previous section based on the current heading level

| Heading level | Font size | Preceding spacing |
| --- | --- | --- |
| First level | 16px | 12px |
| Second level | 18px | 16px |
| Third level | 20px | 20px |
| Fourth level | 24px | 24px |
| Fifth level | 30px | 28px |

Set the preceding spacing of the first heading in a container to 0px, retaining the container's own padding
Use 4px when a heading immediately follows a parent heading, without adding the preceding spacing from the table
Always specify spacing in the following element's `margin-top` and set the preceding element's `margin-bottom` to 0px
Follow the respective rules for internal spacing in title bars, field rows, forms, button areas, and other components
## 6 Text

Text style combines font size, color, and weight, with each dimension selected for the usage scenario

### 6.1 Font Size

Use 14px as the base size for body text, make headings within the body bold, and increase the font size level by level starting from the level closest to body text
Use `text-heading` for headings within the body, place each on its own line, prefix it with an emoji that represents the topic, and include only the topic name
Set the spacing between body headings and paragraphs according to [§5.8](#58-text-hierarchy-spacing)

| Font size | Usage scenario |
| --- | --- |
| 30px | Fifth-level heading, Heading 0 |
| 24px | Fourth-level heading, Heading 1 |
| 20px | Third-level heading, Heading 2 |
| 18px | Second-level heading, Heading 3 |
| 16px | First-level heading, Heading 4 |
| 14px | Body text, field labels, field values, form field names, error causes, action text |
| 12px | Supporting information such as time, source, and additional notes |
| 10px | Not currently used |

<div class="card-mockup" style="width:100%;box-sizing:border-box;min-width:0;border:1px solid #dee0e3;border-radius:8px;overflow:hidden;background:#fff;color:#1f2329;font-family:system-ui,sans-serif;font-size:14px;font-weight:400;line-height:1.6">
<div class="card-header theme-green" style="padding:8px 12px;background:#eaf9e6;color:#237804">
<div class="card-title" style="font-size:14px;font-weight:600;line-height:22px;color:inherit">🎉 Chestnut Store v2.0.0 release</div>
</div>
<div style="padding:10px 12px">
<div class="text-heading" style="font-size:18px;font-weight:700;margin:0">🎯 Order placement workflow redesign</div>
<div class="text-heading" style="font-size:16px;font-weight:700;margin:4px 0 0">📍 Scope</div>
<div style="margin:4px 0 0">Shopping cart, checkout, and order details</div>
<div class="text-heading" style="font-size:16px;font-weight:700;margin:12px 0 0">📢 Impact</div>
<div style="margin:4px 0 0">View existing orders as usual, with no action required</div>
<div class="text-grey" style="font-size:12px;color:#646a73;margin:8px 0 0">⏰ 2026-09-29 18:30</div>
</div>
</div>

### 6.2 Text Color

| Text color | HTML color code (light mode) | Usage scenario |
| --- | --- | --- |
| Dark | `#1f2329` | Headings within the body, body text, field values, error causes, and required actions |
| Gray `text-grey` | `#646a73` | Field labels, time, source, additional notes |
| Light gray | `#8f959e` | Input placeholders, text in disabled controls |
| Red `text-red` | `#c02a26` | Critical warnings or errors that need emphasis, required field indicators |

Use `is-placeholder` for placeholder text and `is-disabled` for disabled controls

<div class="card-mockup" style="width:100%;box-sizing:border-box;min-width:0;border:1px solid #dee0e3;border-radius:8px;overflow:hidden;background:#fff;color:#1f2329;font-family:system-ui,sans-serif;font-size:14px;font-weight:400;line-height:1.6">
<div class="card-header theme-blue" style="padding:8px 12px;background:#e8f1ff;color:#1f5bd6">
<div class="card-title" style="font-size:14px;font-weight:600;line-height:22px;color:inherit">Create follow-up task</div>
</div>
<form name="form_followup_task" style="padding:10px 12px">
<div class="form-label" data-field-name="task_name" style="font-weight:700;color:#1f2329">Task name <span class="text-red" style="color:#c02a26">*</span></div>
<div class="card-input input-single is-required" data-field-name="task_name" style="border:1px solid #dee0e3;border-radius:6px;padding:6px 8px;color:#1f2329" data-value="Follow up with customers who left negative reviews for the chestnut gift box">Follow up with customers who left negative reviews for the chestnut gift box</div>
<div class="form-label" data-field-name="owner" style="font-weight:700;margin-top:8px;color:#1f2329">Owner <span class="text-red" style="color:#c02a26">*</span></div>
<div class="card-select select-person-single is-required" data-field-name="owner" style="border:1px solid #c02a26;border-radius:6px;padding:6px 8px;color:#8f959e" data-options-key="assignees"><span class="is-placeholder">Select an owner</span> ▾</div>
<div class="text-red" style="color:#c02a26">Select an owner</div>
<div class="text-grey" style="font-size:12px;color:#646a73;margin-top:8px">Source: Chestnut Store after-sales support group</div>
<hr style="border:0;border-top:1px solid #dee0e3;margin:12px 0">
<div class="button-area" style="display:flex;flex-wrap:wrap;gap:8px">
<span class="card-button button-primary button-callback form-submit" data-field-name="submit" data-action="create_task" data-object-key="current-object" style="display:inline-block;padding:4px 12px;border:1px solid #94b4ff;border-radius:6px;background:#fff;color:#1456f0">✅ Create task</span>
<span class="card-button button-default button-callback form-cancel" data-field-name="cancel" data-action="cancel" data-object-key="current-object" style="display:inline-block;padding:4px 12px;border:1px solid #dee0e3;border-radius:6px;background:#fff;color:#1f2329">🚫 Cancel</span>
</div>
</form>
</div>

### 6.3 Font Weight

| Font weight | HTML setting | Usage scenario |
| --- | --- | --- |
| Regular | `font-weight:400` | Body text, subtitles, and supporting information |
| Semibold | `font-weight:600` | Main card title |
| Bold | `font-weight:700` | Body headings, form field names, and key content |

Except for the critical alerts in [§6.2](#62-text-color), change only the font weight to emphasize specific text

### 6.4 Code Style

Use inline code style for business identifiers, such as task numbers, order numbers, and product IDs, to distinguish them from normal body text
In mockups, use `<code>` to display identifiers with a 14px monospace font, text color `#1f2329`, background color `#f5f6f7`, a 4px corner radius, and padding of 2px vertically and 4px horizontally

<div class="card-mockup" style="width:100%;box-sizing:border-box;min-width:0;border:1px solid #dee0e3;border-radius:8px;overflow:hidden;background:#fff;color:#1f2329;font-family:system-ui,sans-serif;font-size:14px;font-weight:400;line-height:1.6">
<div class="card-header theme-blue" style="padding:8px 12px;background:#e8f1ff;color:#1f5bd6">
<div class="card-title" style="font-size:14px;font-weight:600;line-height:22px;color:inherit">Order details</div>
</div>
<div style="padding:10px 12px">
<div class="field-row" style="display:flex;gap:12px;margin:4px 0"><div class="field-label text-grey" style="flex:0 0 64px;color:#646a73">Order number</div><div class="field-value" style="flex:1;min-width:0;color:#1f2329"><code style="font-family:ui-monospace,Consolas,monospace;font-size:14px;color:#1f2329;background:#f5f6f7;border-radius:4px;padding:2px 4px">A3K9F2</code></div></div>
<div class="field-row" style="display:flex;gap:12px;margin:4px 0"><div class="field-label text-grey" style="flex:0 0 64px;color:#646a73">Product name</div><div class="field-value" style="flex:1;min-width:0;color:#1f2329">Chestnut gift box</div></div>
</div>
</div>

### 6.5 Common Text Styles

| Usage scenario | Font size | Color (light mode) | Font weight |
| --- | --- | --- | --- |
| Headings within the body | 16, 18, 20, 24, or 30px according to heading level | `#1f2329` | 700 |
| Form field names | 14px | `#1f2329` | 700 |
| Body text, field values, required actions | 14px | `#1f2329` | 400 |
| Field row labels | 14px | `#646a73` | 400 |
| Time, source, additional notes, pagination range and total count | 12px | `#646a73` | 400 |
| Input placeholders | 14px | `#8f959e` | 400 |
| Error messages | 14px | `#c02a26` | 400 |
| Critical warnings that need emphasis | 14px | `#c02a26` | 700 |

## 7 Icons and Markers

Choose emoji by topic or action, and use consistent markers for similar information
Show emoji together with text

### 7.1 Status Markers

| Marker | Meaning | Example |
| --- | --- | --- |
| ✅ | Success | ✅ Import successful |
| ⏳ | Waiting, processing | ⏳ Not yet generated |
| ⚪ | Not yet started | ⚪ Not started |
| ⚠️ | Warning, needs attention | ⚠️ Some imports failed |
| ❌ | Failure, error | ❌ Read failed |
| ❔ | Unknown result, awaiting confirmation | ❔ Result awaiting confirmation |
| — | Not applicable, not performed | — Not applicable |

Pair status markers with text, and do not distinguish statuses by color alone

### 7.2 Leading Icons

To identify a platform, brand, or app, show its actual icon before its name
Set both icon dimensions to 1 times the adjacent text size, preserve the original aspect ratio, and center the icon vertically with the name
Use `<img class="row-icon">` to show the actual icon in the mockup, and do not approximate it with emoji

<div class="card-mockup" style="width:100%;box-sizing:border-box;min-width:0;border:1px solid #dee0e3;border-radius:8px;overflow:hidden;background:#fff;color:#1f2329;font-family:system-ui,sans-serif;font-size:14px;font-weight:400;line-height:1.6">
<div style="padding:10px 12px">
<div style="display:flex;align-items:center;gap:4px;margin:4px 0"><img class="row-icon" src="assets/lark-card/apple.png" alt="iOS" style="width:1em;height:1em;flex:0 0 1em;object-fit:contain"> <a href="https://apps.apple.com/app/id728293409">Monument Valley</a></div>
<div style="display:flex;align-items:center;gap:4px;margin:4px 0"><img class="row-icon" src="assets/lark-card/android.png" alt="Android" style="width:1em;height:1em;flex:0 0 1em;object-fit:contain"> <a href="https://play.google.com/store/apps/details?id=com.ustwo.monumentvalley">Monument Valley</a></div>
<div style="display:flex;align-items:center;gap:4px;margin:4px 0"><img class="row-icon" src="assets/lark-card/app-store.png" alt="App Store" style="width:1em;height:1em;flex:0 0 1em;object-fit:contain"> <a href="https://apps.apple.com/">App Store</a></div>
<div style="display:flex;align-items:center;gap:4px;margin:4px 0"><img class="row-icon" src="assets/lark-card/google-play.png" alt="Google Play" style="width:1em;height:1em;flex:0 0 1em;object-fit:contain"> <a href="https://play.google.com/store/apps">Google Play</a></div>
</div>
</div>

## 8 People

Represent people in body text with avatar capsules, with a circular avatar on the left and a name on the right
Use `person-capsule` for avatar capsules and `data-person-key` to identify the corresponding person in the business context
Use a 20 × 20px avatar, a name in 14px `#1f2329` regular text, and a 4px gap between the avatar and name
Use a `#f5f6f7` capsule background, a 999px corner radius, and padding of 2px vertically and 8px horizontally
Place multiple people side by side in a field row with an 8px gap between capsules, and wrap when they do not fit the current width
Keep the avatar and name together within each capsule, and do not shrink either
Use only names for people in titles and buttons
When person information is unavailable, show the corresponding missing-information text instead of an empty capsule

<div class="card-mockup" style="width:100%;box-sizing:border-box;min-width:0;border:1px solid #dee0e3;border-radius:8px;overflow:hidden;background:#fff;color:#1f2329;font-family:system-ui,sans-serif;font-size:14px;font-weight:400;line-height:1.6">
<div style="padding:10px 12px">
<div class="field-row" style="display:flex;align-items:center;gap:12px;margin:4px 0"><div class="field-label text-grey" style="flex:0 0 64px;font-size:14px;color:#646a73">Owner</div><div class="field-value" style="flex:1;min-width:0"><span class="person-capsule" data-person-key="owner" style="display:inline-flex;align-items:center;gap:4px;padding:2px 8px;border-radius:999px;background:#f5f6f7;color:#1f2329;white-space:nowrap"><img src="assets/lark-card/avatar-zhang.jpg" alt="Example avatar for Alex Smith" width="20" height="20" style="flex:0 0 20px;border-radius:50%;object-fit:cover">Alex Smith</span></div></div>
<div class="field-row" style="display:flex;align-items:center;gap:12px;margin:4px 0"><div class="field-label text-grey" style="flex:0 0 64px;font-size:14px;color:#646a73">Related people</div><div class="field-value" style="display:flex;flex-wrap:wrap;gap:8px;flex:1;min-width:0"><span class="person-capsule" data-person-key="related-1" style="display:inline-flex;align-items:center;gap:4px;padding:2px 8px;border-radius:999px;background:#f5f6f7;color:#1f2329;white-space:nowrap"><img src="assets/lark-card/avatar-li.jpg" alt="Example avatar for Jamie Brown" width="20" height="20" style="flex:0 0 20px;border-radius:50%;object-fit:cover">Jamie Brown</span><span class="person-capsule" data-person-key="related-2" style="display:inline-flex;align-items:center;gap:4px;padding:2px 8px;border-radius:999px;background:#f5f6f7;color:#1f2329;white-space:nowrap"><img src="assets/lark-card/avatar-wang.jpg" alt="Example avatar for Taylor Wilson" width="20" height="20" style="flex:0 0 20px;border-radius:50%;object-fit:cover">Taylor Wilson</span></div></div>
</div>
</div>

## 9 Actions and Inputs

### 9.1 Buttons

Use `card-button` for buttons, with exactly one style class
Use `button-callback` for callback buttons, `data-action` to identify the action, and `data-object-key` to identify the business object
Use `<a>` and `button-open-url` for link buttons, with `href` specifying the target URL
Give each button exactly one interaction class

| Style class | Border | Text | When to use |
| --- | --- | --- | --- |
| `button-default` | `#dee0e3` | `#1f2329` | Standard actions |
| `button-primary` | `#94b4ff` | `#1456f0` | The primary action in the current action area |
| `button-danger` | `#f89e9b` | `#f54a45` | Irreversible actions such as voiding, deleting, or removing |
| Disabled state | `#eff0f1` | `#8f959e` | Actions that cannot currently be performed |

Use a `#ffffff` button background, a 1px solid border, a 6px corner radius, and padding of 4px vertically and 12px horizontally
Use 14px regular text for buttons and an 8px gap between buttons
Use `button-area` for a separate action area, and place it at the end of the object or card
Arrange multiple buttons horizontally, and wrap when they do not fit the current width
Place the primary action on the left, followed by secondary actions, with cancel and discard actions on the far right
Button text states only the current action, preceded by an emoji that represents the action
Put details such as object counts in the body text

<div class="card-mockup" style="width:100%;box-sizing:border-box;min-width:0;border:1px solid #dee0e3;border-radius:8px;overflow:hidden;background:#fff;color:#1f2329;font-family:system-ui,sans-serif;font-size:14px;font-weight:400;line-height:1.6">
<div class="card-header theme-blue" style="padding:8px 12px;background:#e8f1ff;color:#1f5bd6">
<div class="card-title" style="font-size:14px;font-weight:600;line-height:22px;color:inherit">Follow-up task · ⏳ Awaiting confirmation</div>
</div>
<div style="padding:10px 12px">
<div>Follow up with customers who left negative reviews of the chestnut gift box</div>
<hr style="border:0;border-top:1px solid #dee0e3;margin:12px 0">
<div class="button-area" style="display:flex;flex-wrap:wrap;gap:8px">
<span class="card-button button-primary button-callback" data-action="create_task" data-object-key="current-object" style="display:inline-block;padding:4px 12px;border:1px solid #94b4ff;border-radius:6px;background:#fff;color:#1456f0">✅ Confirm creation</span>
<span class="card-button button-default button-callback" data-action="cancel" data-object-key="current-object" style="display:inline-block;padding:4px 12px;border:1px solid #dee0e3;border-radius:6px;background:#fff;color:#1f2329">🚫 Cancel</span>
</div>
</div>
</div>

<div class="card-mockup" style="width:100%;box-sizing:border-box;min-width:0;border:1px solid #dee0e3;border-radius:8px;overflow:hidden;background:#fff;color:#1f2329;font-family:system-ui,sans-serif;font-size:14px;font-weight:400;line-height:1.6">
<div class="card-header theme-grey" style="padding:8px 12px;background:#646a73;color:#ffffff">
<div class="card-title" style="font-size:14px;font-weight:600;line-height:22px;color:inherit">Void product record · ⏳ Awaiting confirmation</div>
</div>
<div style="padding:10px 12px">
<div>Chestnut gift box</div>
<div>Cannot be restored after voiding</div>
<hr style="border:0;border-top:1px solid #dee0e3;margin:12px 0">
<div class="button-area" style="display:flex;flex-wrap:wrap;gap:8px">
<span class="card-button button-danger button-callback" data-action="confirm_void" data-object-key="current-object" style="display:inline-block;padding:4px 12px;border:1px solid #f89e9b;border-radius:6px;background:#fff;color:#f54a45">🗑 Confirm voiding</span>
<span class="card-button button-default button-callback" data-action="cancel" data-object-key="current-object" style="display:inline-block;padding:4px 12px;border:1px solid #dee0e3;border-radius:6px;background:#fff;color:#1f2329">🚫 Cancel</span>
</div>
</div>
</div>

<div class="card-mockup" style="width:100%;box-sizing:border-box;min-width:0;border:1px solid #dee0e3;border-radius:8px;overflow:hidden;background:#fff;color:#1f2329;font-family:system-ui,sans-serif;font-size:14px;font-weight:400;line-height:1.6">
<div class="card-header theme-blue" style="padding:8px 12px;background:#e8f1ff;color:#1f5bd6">
<div class="card-title" style="font-size:14px;font-weight:600;line-height:22px;color:inherit">Follow-up task · ⏳ Creating</div>
</div>
<div style="padding:10px 12px">
<div>Follow up with customers who left negative reviews of the chestnut gift box</div>
<hr style="border:0;border-top:1px solid #dee0e3;margin:12px 0">
<div class="button-area" style="display:flex;flex-wrap:wrap;gap:8px">
<span class="card-button button-primary is-disabled button-callback" data-action="create_task" data-object-key="current-object" style="display:inline-block;padding:4px 12px;border:1px solid #eff0f1;border-radius:6px;background:#fff;color:#8f959e">⏳ Creating</span>
</div>
</div>
</div>

### 9.2 Forms

Use `<form name="form_identifier">` for forms, with a unique name within the card
Use a form when users need to enter or select values, with a submit and cancel action area at the bottom
Use `form-label` for field labels, with `data-field-name` corresponding to the control name
Use `is-required` for required controls
Use `form-submit` for submit buttons, with `data-field-name` providing the button name
Use `form-cancel` for cancel buttons, with `data-field-name` providing the button name
Place field labels above controls in 14px `#1f2329` bold text, and append a "*" in `#c02a26` to required field labels
Use a 4px gap between a field label and its control, and a 12px gap between adjacent field groups
Use `card-input` for input boxes, with `input-single` for single-line inputs and `input-multiline` for multiline inputs
Use `data-value` for prefilled input values, and display the prefilled content directly inside the corresponding control
Use `card-select` for dropdowns, with `select-single`, `select-multi`, `select-person-single`, or `select-person-multi` specifying the type
Use `data-options-key` to identify the option list for dropdown controls
Use `data-value` for the initial value of a standard single-select control, and a JSON string array in `data-values` for a multi-select control
Use `data-person-key` for the initially selected person in a single-select person control, and a JSON identifier array in `data-person-keys` for a multi-select person control
Show "▾" on the right of dropdowns, render person selectors as dropdowns, and show the names of selected people
Display field validation errors below the corresponding controls in 14px `#c02a26` regular text
Place submission failure messages above the buttons in the bottom action area, and retain entered content in the controls

<div class="card-mockup" style="width:100%;box-sizing:border-box;min-width:0;border:1px solid #dee0e3;border-radius:8px;overflow:hidden;background:#fff;color:#1f2329;font-family:system-ui,sans-serif;font-size:14px;font-weight:400;line-height:1.6">
<div class="card-header theme-blue" style="padding:8px 12px;background:#e8f1ff;color:#1f5bd6">
<div class="card-title" style="font-size:14px;font-weight:600;line-height:22px;color:inherit">Create follow-up task</div>
</div>
<form name="form_followup_task" style="padding:10px 12px">
<div class="form-label" data-field-name="task_name" style="font-weight:700;color:#1f2329;margin:0 0 4px">Task name <span class="text-red" style="color:#c02a26">*</span></div>
<div class="card-input input-single is-required" data-field-name="task_name" style="padding:6px 8px;border:1px solid #dee0e3;border-radius:6px" data-value="Follow up with customers who left negative reviews of the chestnut gift box">Follow up with customers who left negative reviews of the chestnut gift box</div>
<div class="form-label" data-field-name="owner" style="font-weight:700;color:#1f2329;margin:12px 0 4px">Owner <span class="text-red" style="color:#c02a26">*</span></div>
<div class="card-select select-person-single is-required" data-field-name="owner" style="padding:6px 8px;border:1px solid #dee0e3;border-radius:6px;color:#8f959e" data-options-key="assignees"><span class="is-placeholder">Select an owner</span> ▾</div>
<div class="form-label" data-field-name="note" style="font-weight:700;color:#1f2329;margin:12px 0 4px">Additional notes</div>
<div class="card-input input-multiline" data-field-name="note" style="padding:6px 8px;border:1px solid #dee0e3;border-radius:6px;min-height:44px;color:#8f959e"><span class="is-placeholder">Optional, line breaks allowed</span></div>
<hr style="border:0;border-top:1px solid #dee0e3;margin:12px 0">
<div class="button-area" style="display:flex;flex-wrap:wrap;gap:8px">
<span class="card-button button-primary button-callback form-submit" data-field-name="submit" data-action="create_task" data-object-key="current-object" style="display:inline-block;padding:4px 12px;border:1px solid #94b4ff;border-radius:6px;background:#fff;color:#1456f0">✅ Create task</span>
<span class="card-button button-default button-callback form-cancel" data-field-name="cancel" data-action="cancel" data-object-key="current-object" style="display:inline-block;padding:4px 12px;border:1px solid #dee0e3;border-radius:6px;background:#fff;color:#1f2329">🚫 Cancel</span>
</div>
</form>
</div>

<div class="card-mockup" style="width:100%;box-sizing:border-box;min-width:0;border:1px solid #dee0e3;border-radius:8px;overflow:hidden;background:#fff;color:#1f2329;font-family:system-ui,sans-serif;font-size:14px;font-weight:400;line-height:1.6">
<div class="card-header theme-orange" style="padding:8px 12px;background:#fff1e6;color:#d46b08">
<div class="card-title" style="font-size:14px;font-weight:600;line-height:22px;color:inherit">Create follow-up task · ⚠️ Complete the required information</div>
</div>
<form name="form_followup_task" style="padding:10px 12px">
<div class="form-label" data-field-name="task_name" style="font-weight:700;color:#1f2329;margin:0 0 4px">Task name <span class="text-red" style="color:#c02a26">*</span></div>
<div class="card-input input-single is-required" data-field-name="task_name" style="padding:6px 8px;border:1px solid #dee0e3;border-radius:6px" data-value="Follow up with customers who gave negative reviews of the chestnut gift box">Follow up with customers who gave negative reviews of the chestnut gift box</div>
<div class="form-label" data-field-name="owner" style="font-weight:700;color:#1f2329;margin:12px 0 4px">Assignee <span class="text-red" style="color:#c02a26">*</span></div>
<div class="card-select select-person-single is-required" data-field-name="owner" style="padding:6px 8px;border:1px solid #c02a26;border-radius:6px;color:#8f959e" data-options-key="assignees"><span class="is-placeholder">Select an assignee</span> ▾</div>
<div class="text-red" style="color:#c02a26;margin-top:4px">Select an assignee</div>
<div class="form-label" data-field-name="note" style="font-weight:700;color:#1f2329;margin:12px 0 4px">Additional notes</div>
<div class="card-input input-multiline" data-field-name="note" style="padding:6px 8px;border:1px solid #dee0e3;border-radius:6px;min-height:44px;color:#8f959e"><span class="is-placeholder">Optional, line breaks allowed</span></div>
<hr style="border:0;border-top:1px solid #dee0e3;margin:12px 0">
<div class="button-area" style="display:flex;flex-wrap:wrap;gap:8px">
<span class="card-button button-primary button-callback form-submit" data-field-name="submit" data-action="create_task" data-object-key="current-object" style="display:inline-block;padding:4px 12px;border:1px solid #94b4ff;border-radius:6px;background:#fff;color:#1456f0">✅ Create task</span>
<span class="card-button button-default button-callback form-cancel" data-field-name="cancel" data-action="cancel" data-object-key="current-object" style="display:inline-block;padding:4px 12px;border:1px solid #dee0e3;border-radius:6px;background:#fff;color:#1f2329">🚫 Cancel</span>
</div>
</form>
</div>

<div class="card-mockup" style="width:100%;box-sizing:border-box;min-width:0;border:1px solid #dee0e3;border-radius:8px;overflow:hidden;background:#fff;color:#1f2329;font-family:system-ui,sans-serif;font-size:14px;font-weight:400;line-height:1.6">
<div class="card-header theme-red" style="padding:8px 12px;background:#fdecec;color:#d83931">
<div class="card-title" style="font-size:14px;font-weight:600;line-height:22px;color:inherit">Create follow-up task · ❌ Creation failed</div>
</div>
<form name="form_followup_task" style="padding:10px 12px">
<div class="form-label" data-field-name="task_name" style="font-weight:700;color:#1f2329;margin:0 0 4px">Task name <span class="text-red" style="color:#c02a26">*</span></div>
<div class="card-input input-single is-required" data-field-name="task_name" style="padding:6px 8px;border:1px solid #dee0e3;border-radius:6px" data-value="Follow up with customers who gave negative reviews of the chestnut gift box">Follow up with customers who gave negative reviews of the chestnut gift box</div>
<div class="form-label" data-field-name="owner" style="font-weight:700;color:#1f2329;margin:12px 0 4px">Assignee <span class="text-red" style="color:#c02a26">*</span></div>
<div class="card-select select-person-single is-required" data-field-name="owner" style="padding:6px 8px;border:1px solid #dee0e3;border-radius:6px;color:#1f2329" data-options-key="assignees" data-person-key="related-1">James Smith ▾</div>
<div class="form-label" data-field-name="note" style="font-weight:700;color:#1f2329;margin:12px 0 4px">Additional notes</div>
<div class="card-input input-multiline" data-field-name="note" style="padding:6px 8px;border:1px solid #dee0e3;border-radius:6px;min-height:44px;color:#1f2329" data-value="Check whether the gift box arrived damaged">Check whether the gift box arrived damaged</div>
<hr style="border:0;border-top:1px solid #dee0e3;margin:12px 0">
<div class="text-red" style="color:#c02a26;margin-bottom:8px">Save failed, try again</div>
<div class="button-area" style="display:flex;flex-wrap:wrap;gap:8px">
<span class="card-button button-primary button-callback form-submit" data-field-name="submit" data-action="create_task" data-object-key="current-object" style="display:inline-block;padding:4px 12px;border:1px solid #94b4ff;border-radius:6px;background:#fff;color:#1456f0">✅ Create task</span>
<span class="card-button button-default button-callback form-cancel" data-field-name="cancel" data-action="cancel" data-object-key="current-object" style="display:inline-block;padding:4px 12px;border:1px solid #dee0e3;border-radius:6px;background:#fff;color:#1f2329">🚫 Cancel</span>
</div>
</form>
</div>

### 9.3 Date and Time

Use `card-datetime` for date and time controls and `data-value` for prefilled values
`data-timezone` specifies the business time zone, and the field label displays the corresponding time zone name
When no date and time is selected, the control displays “📅 Select time” in 14px `#8f959e` regular text
When a date and time is selected, the control displays the specific date and time, such as “2026-10-08 18:30”, in 14px `#1f2329` regular text

<div class="card-mockup" style="width:100%;box-sizing:border-box;min-width:0;border:1px solid #dee0e3;border-radius:8px;overflow:hidden;background:#fff;color:#1f2329;font-family:system-ui,sans-serif;font-size:14px;font-weight:400;line-height:1.6">
<div class="card-header theme-blue" style="padding:8px 12px;background:#e8f1ff;color:#1f5bd6">
<div class="card-title" style="font-size:14px;font-weight:600;line-height:22px;color:inherit">Adjust delivery time</div>
</div>
<form name="form_delivery_time" style="padding:10px 12px">
<div>Design the login page</div>
<div class="form-label" data-field-name="delivery_time" style="font-weight:700;margin:12px 0 4px">Delivery time (Beijing time) <span class="text-red" style="color:#c02a26">*</span></div>
<div class="card-datetime is-required" data-field-name="delivery_time" style="padding:6px 8px;border:1px solid #dee0e3;border-radius:6px;color:#8f959e" data-timezone="Asia/Shanghai">📅 <span class="is-placeholder">Select time</span></div>
<hr style="border:0;border-top:1px solid #dee0e3;margin:12px 0">
<div class="button-area" style="display:flex;flex-wrap:wrap;gap:8px">
<span class="card-button button-primary button-callback form-submit" data-field-name="submit" data-action="save" data-object-key="current-object" style="display:inline-block;padding:4px 12px;border:1px solid #94b4ff;border-radius:6px;background:#fff;color:#1456f0">✅ Save</span>
<span class="card-button button-default button-callback form-cancel" data-field-name="cancel" data-action="cancel" data-object-key="current-object" style="display:inline-block;padding:4px 12px;border:1px solid #dee0e3;border-radius:6px;background:#fff;color:#1f2329">🚫 Cancel</span>
</div>
</form>
</div>

<div class="card-mockup" style="width:100%;box-sizing:border-box;min-width:0;border:1px solid #dee0e3;border-radius:8px;overflow:hidden;background:#fff;color:#1f2329;font-family:system-ui,sans-serif;font-size:14px;font-weight:400;line-height:1.6">
<div class="card-header theme-blue" style="padding:8px 12px;background:#e8f1ff;color:#1f5bd6">
<div class="card-title" style="font-size:14px;font-weight:600;line-height:22px;color:inherit">Adjust delivery time</div>
</div>
<form name="form_delivery_time" style="padding:10px 12px">
<div>Design the login page</div>
<div class="form-label" data-field-name="delivery_time" style="font-weight:700;margin:12px 0 4px">Delivery time (Beijing time) <span class="text-red" style="color:#c02a26">*</span></div>
<div class="card-datetime is-required" data-field-name="delivery_time" style="padding:6px 8px;border:1px solid #dee0e3;border-radius:6px;color:#1f2329" data-value="2026-10-08 18:30" data-timezone="Asia/Shanghai">2026-10-08 18:30</div>
<hr style="border:0;border-top:1px solid #dee0e3;margin:12px 0">
<div class="button-area" style="display:flex;flex-wrap:wrap;gap:8px">
<span class="card-button button-primary button-callback form-submit" data-field-name="submit" data-action="save" data-object-key="current-object" style="display:inline-block;padding:4px 12px;border:1px solid #94b4ff;border-radius:6px;background:#fff;color:#1456f0">✅ Save</span>
<span class="card-button button-default button-callback form-cancel" data-field-name="cancel" data-action="cancel" data-object-key="current-object" style="display:inline-block;padding:4px 12px;border:1px solid #dee0e3;border-radius:6px;background:#fff;color:#1f2329">🚫 Cancel</span>
</div>
</form>
</div>

## 10 Progress Display

### 10.1 Progress Bar

Use `progress-bar` for progress bars, with `data-completed` for the number of finished items and `data-total` for the total number of items
`data-length` specifies the number of character cells in the bar, based on the available layout width, font size, and length of the text on the right
When the overall progress of the card can be calculated, use a character bar to show the proportion of finished items
The finished item count includes successful and failed items, but excludes items that are processing, not started, or have unknown results
Use "█" for the finished portion and "░" for the remaining portion, and calculate the number of filled cells by dividing the finished item count by the total item count, multiplying by the number of character cells, and rounding down
Use inline code styling for the progress bar and vertically center it with the count on the right
`data-format` is either `ratio` or `percent`, with `ratio` as the default
Show the count ratio or percentage to the right of the progress bar in 14px bold text, such as "1/2", "3/16", or "50%"

<div class="card-mockup" style="width:100%;box-sizing:border-box;min-width:0;border:1px solid #dee0e3;border-radius:8px;overflow:hidden;background:#fff;color:#1f2329;font-family:system-ui,sans-serif;font-size:14px;font-weight:400;line-height:1.6">
<div class="card-header theme-blue" style="padding:8px 12px;background:#e8f1ff;color:#1f5bd6">
<div class="card-title" style="font-size:14px;font-weight:600;line-height:22px;color:inherit">Data import · ⏳ Processing</div>
</div>
<div style="padding:10px 12px">
<div class="progress-bar" data-completed="1" data-total="2" data-length="16" data-format="ratio" style="display:flex;align-items:center;gap:8px"><code style="flex:0 0 auto;font-family:Consolas,'Cascadia Mono','DejaVu Sans Mono',monospace;font-size:16px;line-height:16px;color:#1f2329;background:#f5f6f7;border-radius:4px;padding:2px 4px;white-space:nowrap"><span style="display:block;height:16px;line-height:16px;overflow:hidden">████████░░░░░░░░</span></code><span style="font-weight:700">1/2</span></div>
</div>
</div>

### 10.2 Step Progress

Use `<ol class="step-progress">` for step progress
Show each step and its status in workflow order, with related details below the corresponding step

<div class="card-mockup" style="width:100%;box-sizing:border-box;min-width:0;border:1px solid #dee0e3;border-radius:8px;overflow:hidden;background:#fff;color:#1f2329;font-family:system-ui,sans-serif;font-size:14px;font-weight:400;line-height:1.6">
<div class="card-header theme-blue" style="padding:8px 12px;background:#e8f1ff;color:#1f5bd6">
<div class="card-title" style="font-size:14px;font-weight:600;line-height:22px;color:inherit">Data import · ⏳ Processing</div>
</div>
<div style="padding:10px 12px">
<div>Product Data.xlsx</div>
<ol class="step-progress" style="margin:4px 0 0;padding-left:20px">
<li>Read: ✅ Completed</li>
<li>Validate: ✅ Completed</li>
<li>Write: ⏳ Processing<div class="text-grey" style="font-size:12px;color:#646a73">120/300 rows written</div></li>
<li>Generate results: ⚪ Not started</li>
</ol>
</div>
</div>

## 11 Attachments

Use `<img class="attachment-thumbnail">` for image thumbnails
Use `attachment-gallery` for thumbnail groups
Use actual image thumbnails for image attachments, sized at 56 × 56px with 6px rounded corners, proportionally scaled and center-cropped
During design, determine the number of thumbnails per row based on the available width in the usage environment, with 8px spacing between thumbnails
If not all images are shown, provide a "🖼️ View all" button in the bottom action area
Write the total image count below the thumbnails in 12px `#646a73` regular text
Present files as links labeled "📄 File name"

<div class="card-mockup" style="width:100%;box-sizing:border-box;min-width:0;border:1px solid #dee0e3;border-radius:8px;overflow:hidden;background:#fff;color:#1f2329;font-family:system-ui,sans-serif;font-size:14px;font-weight:400;line-height:1.6">
<div class="card-header theme-blue" style="padding:8px 12px;background:#e8f1ff;color:#1f5bd6">
<div class="card-title" style="font-size:14px;font-weight:600;line-height:22px;color:inherit">Venue information</div>
</div>
<div style="padding:10px 12px">
<div class="text-heading" style="font-size:16px;font-weight:700">📎 Attachments</div>
<div class="attachment-gallery" style="display:flex;gap:8px;margin-top:8px">
<img class="attachment-thumbnail" src="assets/lark-card/attachment-room.jpg" alt="Venue living room" width="56" height="56" style="flex:0 0 56px;border-radius:6px;object-fit:cover">
<img class="attachment-thumbnail" src="assets/lark-card/attachment-desk.jpg" alt="Venue workspace" width="56" height="56" style="flex:0 0 56px;border-radius:6px;object-fit:cover">
<img class="attachment-thumbnail" src="assets/lark-card/attachment-shelf.jpg" alt="Venue furnishings" width="56" height="56" style="flex:0 0 56px;border-radius:6px;object-fit:cover">
<img class="attachment-thumbnail" src="assets/lark-card/attachment-bedroom.jpg" alt="Venue bedroom" width="56" height="56" style="flex:0 0 56px;border-radius:6px;object-fit:cover">
<img class="attachment-thumbnail" src="assets/lark-card/attachment-kitchen.jpg" alt="Venue kitchen" width="56" height="56" style="flex:0 0 56px;border-radius:6px;object-fit:cover">
</div>
<div class="text-grey" style="font-size:12px;color:#646a73;margin-top:4px">8 images in total</div>
<div style="margin-top:8px">📄 <a href="https://example.com/files/venue-info.pdf">Venue Information.pdf</a></div>
<hr style="border:0;border-top:1px solid #dee0e3;margin:12px 0">
<div class="button-area" style="display:flex;flex-wrap:wrap;gap:8px">
<span class="card-button button-default button-callback" data-action="view_all_attachments" data-object-key="current-object" style="display:inline-block;padding:4px 12px;border:1px solid #dee0e3;border-radius:6px;background:#fff;color:#1f2329">🖼️ View all</span>
</div>
</div>
</div>

## 12 Checklist

### 12.1 Scenarios and States

- [ ] All user-visible scenarios and states have complete card mockups
- [ ] Dynamic content uses specific example values that match the current scenario and state
- [ ] Key statuses and information required for actions are directly visible

### 12.2 Layout

- [ ] Cards adapt to the available host width, and information and actions remain fully usable at the minimum supported width
- [ ] Field rows use a true two-column structure, and long values wrap within their own columns
- [ ] A divider separates standalone action areas from the body, and inline buttons are vertically centered with the content
- [ ] Table layouts align by column, with content columns left-aligned and the header and buttons in the rightmost action column centered
- [ ] Outlined boxes, gray background blocks, and action blocks conform to their respective scopes
- [ ] Spacing between body headings and paragraphs conforms to [§5.8](#58-text-hierarchy-spacing), with no duplicate spacing applied to the same gap

### 12.3 Platform Capabilities

- [ ] Components and interactions in the mockups map to capabilities supported by Lark (Feishu)
- [ ] HTML effects are not treated as evidence of Lark support
- [ ] Behaviors that require business implementation have an explicit basis in the design or mapping

### 12.4 Progress and Results

- [ ] Progress counting rules are clear, and the number of filled cells matches the count ratio or percentage on the right
- [ ] The dark and light portions of the character bar have the same height and are vertically centered with the value on the right
- [ ] Finished processing is distinguishable from complete success, and unknown results are not shown as failures
- [ ] Steps appear in workflow order, and details belong to their corresponding steps

### 12.5 Actions and Forms

- [ ] Button styles match their purposes, and labels contain only an action and an emoji
- [ ] The order of primary, secondary, and cancel actions is clear, and disabled states are recognizable
- [ ] Required fields, placeholder hints, and prefilled content are distinguishable
- [ ] Field validation errors appear below the corresponding controls, and submission failure messages appear above the bottom buttons
- [ ] Entered content remains visible after submission fails

### 12.6 Capacity and Pagination

- [ ] Capacity and pagination conform to [§3.2](#32-long-content-and-pagination)
- [ ] The pagination method in group chats matches the card's purpose and is specified in the design
- [ ] Changing pages does not change the original card's ownership or business action permissions
- [ ] Confirmation cards and form cards are not paginated, and handling of excess content conforms to their respective rules
- [ ] Pagination mockups retain the associated object, title, and total count, and show the pagination area separately
- [ ] Confirmation details that are not fully listed state the total count clearly, and omitting details from display does not change the confirmation scope

### 12.7 Text and Markers

- [ ] The classes, counts, and styles of the title bar, theme, main title, and subtitle conform to [§4](#4-title-bar)
- [ ] Body headings increase in size at each higher level from the 14px body text baseline, and combinations of font size, color, and weight conform to [§6](#6-text)
- [ ] Business identifiers use code styling, and field labels use 14px gray text
- [ ] Information of the same type uses consistent emoji, and status markers match the meaning of the text

### 12.8 People and Attachments

- [ ] People in the body use avatar pills, while people in titles and buttons appear by name only
- [ ] Icons at the start of a line use actual assets and scale with the adjacent font size
- [ ] Avatars and attachment thumbnails use actual images, and asset sources are registered
- [ ] The number of displayed images is specified in the design, and the total count and view-all entry conform to the attachment rules

### 12.9 Presentation and References

- [ ] Text outside the mockups does not repeat information already conveyed by the mockups
- [ ] Section references resolve, local images load, and HTML structures are complete
- [ ] Assets are saved with the doc, and image paths do not point to local temporary directories