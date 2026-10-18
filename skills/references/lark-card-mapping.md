# Lark Card Mapping

## 1 Scope

Convert each HTML style and feature in the [Lark (Feishu) card mockup](../../doc-design/patterns/lark-card-mockup.md) into a Lark Card JSON 2.0 component or rich text syntax
Use the field definitions in [Card JSON 2.0 Structure](https://open.feishu.cn/document/feishu-cards/card-json-v2-structure) and [Component Overview](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/component-json-v2-overview)
Client display differences and tested limitations are documented in the corresponding sections

## 2 Common Implementation

### 2.1 Text Escaping

Assign dynamic text directly to `plain_text.content`, and output the entire card with a JSON serializer
Convert each ASCII punctuation character in the original dynamic text to `&#decimal_code_point;`, escape it only once, then insert it into the `markdown.content` body, see [Special Character Escaping](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/rich-text)
Validate link URLs with a URL parser, and accept only `http:` and `https:`
After serializing the URL, encode `(` and `)` as `%28` and `%29` to generate the [text link](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/rich-text) syntax `[display text](URL)`
Do not generate a link if URL validation fails, and use the failure display defined by the business design

### 2.2 Sending, Callbacks, and Updates

Generate and save a [UUID v4](https://www.rfc-editor.org/rfc/rfc9562.html#section-5.4) when creating a message to send, and use that message's `uuid` for [sending](https://open.feishu.cn/document/server-docs/im-v1/message/create), [replying](https://open.feishu.cn/document/server-docs/im-v1/message/reply), and retries

1. Call [Create Card Entity](https://open.feishu.cn/document/uAjLw4CM/ukTMukTMukTM/cardkit-v1/card/create), set `type` to `card_json` and `data` to the serialized card JSON, and save the returned `card_id`
2. When [sending or replying with a card message](https://open.feishu.cn/document/server-docs/im-v1/message-content-description/create_json), set `msg_type` to `interactive` and `content` to the serialized string of `{"type":"card","data":{"card_id":"saved card_id"}}`
3. To update, call [CardKit Full Update](https://open.feishu.cn/document/uAjLw4CM/ukTMukTMukTM/cardkit-v1/card/update) with the saved `card_id`, set `card.type` to `card_json` and `card.data` to the serialized complete card JSON

Changes to this card: use CardKit Full Update to update the original card after responding to the callback
Send another card: send a new message after responding to the callback

Respond to [card callbacks](https://open.feishu.cn/document/uAjLw4CM/ukzMukzMukzM/feishu-cards/card-callback-communication) within 3 seconds, and perform time-consuming processing asynchronously
Pass only the action identifier and object identifier in the callback button's `value`, and read business data on the server
Deduplicate retries of the same callback by the [`event_id`](https://open.feishu.cn/document/uAjLw4CM/ukzMukzMukzM/feishu-cards/card-callback-communication) in the callback header
The specific business design defines business idempotency rules for repeated clicks
Execute updates to the same card sequentially, set [`sequence`](https://open.feishu.cn/document/uAjLw4CM/ukTMukTMukTM/cardkit-v1/card/update) to `1` for the first update, and increment it by `1` for each subsequent update request
Card updates do not trigger new message notifications
If an update fails, log `card_id`, `sequence`, the error code, and the error message
If sending returns [error code 230099](https://open.feishu.cn/document/server-docs/im-v1/message/create), locate the card content error using the inner `ErrCode` and field path in `msg`, and do not retry before correcting it
Queue sending requests to the same recipient, with at least 200ms between consecutive requests
If [error code 230020](https://open.feishu.cn/document/server-docs/im-v1/message/create) is returned, retry after waiting 1, 2, and 4 seconds in order, reuse the original `uuid`, and return a sending failure if all three retries fail

## 3 Overall Presentation

Corresponds to [Overall Presentation of the Card Mockup](../../doc-design/patterns/lark-card-mockup.md#3-overall-card-mockup-presentation) in the mockup

### 3.1 Canvas

Generate one card for each `card-mockup` root node using the following fixed skeleton, with fields defined in [JSON 2.0 Structure](https://open.feishu.cn/document/feishu-cards/card-json-v2-structure)
Set `config.width_mode` to `fill` so that Lark displays the card according to the available width of its host
The CSS width, `min-width`, and `box-sizing` in the mockup are used only for HTML layout and do not generate card JSON fields

```json
{
  "schema": "2.0",
  "config": { "width_mode": "fill", "update_multi": true },
  "header": {},
  "body": { "elements": [] }
}
```

### 3.2 Long Content and Pagination

Before sending, count the UTF-8 bytes and components in the serialized complete card

The UTF-8 serialized size must not exceed 30 KB, see the `content` field limit in [Send Message](https://open.feishu.cn/document/server-docs/im-v1/message/create)
Recursively count objects with a `tag` in the complete card, with a maximum of 200, see the element and component count limits in [JSON 2.0 Structure](https://open.feishu.cn/document/feishu-cards/card-json-v2-structure)

Load lists that support pagination as follows

1. Generate the entire card from the complete results, and send it directly without a pagination area if neither the byte count nor the component count exceeds its limit
2. If a limit is exceeded, determine display units in business order, using one unit per record by default and the innermost records as units for nested lists
3. If a single record cannot fit on an empty page, split it into consecutive display units using the oversized record rules below
4. Load display units one at a time, each time generating a complete card that includes the title, summary, parent object identifier and title, and pagination area, and check its capacity
   - If adding the unit exceeds a limit: remove the unit, end this page, and leave the unit for the next page
5. Save the complete results, the display unit sequence, and the starting and ending unit numbers for each page, and read from the saved page boundaries when changing pages without querying business data again

Use stable identifiers to match display units before and after updates
When task progress changes require a refresh of paginated content, repeat the loading steps above using the updated complete content
Use the first display unit on the current page as the anchor, locate it by its stable identifier, and display the new page that contains it
If the anchor unit no longer exists, determine the page to display using the location rules defined by the business design

Confirmation cards do not use pagination and are loaded as follows

1. If a limit is exceeded, retain only the identification fields specified by the business design for each item, then check capacity again
2. If a limit is still exceeded, first generate a complete card that contains the title, last item, ellipsis, total count, and action area
3. Add records one at a time starting with the first item, check the capacity of the entire card each time, and remove the item and stop if a limit is exceeded
4. Display the last item only once
5. Display an ellipsis on its own between the first few items and the last item, followed by a blank line
6. Display the total count for the complete confirmation scope at the end, using the object name and counting unit defined by the business design
7. Retain the numbering from the complete confirmation scope
8. In the confirmation button's `value`, make the object identifier point to the complete confirmation scope saved on the server, and use this identifier in the callback to read all records and perform the action

Form cards do not use pagination, and if a limit is exceeded, remove only descriptions marked as optional by the business design and retain all input fields

If a single record exceeds a limit, summarize only fields marked as summarizable by the business design, then check capacity again
Retain all fields not marked as summarizable in full
If content that supports pagination still exceeds a limit, prefer splitting it into consecutive display units by paragraph or list item
Preserve all content when splitting, and do not truncate characters, links, or rich text structures
Retain the original record identifier and content order in each unit, and retain the parent object's identifier and title on continuation pages

Page-change callbacks read only saved pagination results
Update the original card when changing pages in a private chat
In group chats, use the [page-change method](../../doc-design/patterns/lark-card-mockup.md#32-long-content-and-pagination) selected in the design
Update the original card for shared viewing
For independent browsing, send the person who clicked a browsing card in a private chat that references the same pagination results, and keep the original group chat card unchanged
Private browsing cards retain only browsing and page-change actions, while business confirmation, cancellation, and submission remain on the original card
Page-change callbacks do not change ownership of the original card or business action permissions
Page-change callbacks accept only target pages saved on the server, reject updates if the target page does not exist, and use the failure message defined by the business design

If a limit is still exceeded after applying this section, do not send the card, and use the user message defined by the specific business design

## 4 Title Bar

Corresponds to [Title Bar](../../doc-design/patterns/lark-card-mockup.md#4-title-bar) in the mockup

Generate a native `header` for the title bar, and do not generate duplicate body components for the title and subtitle
The title bar background color, text color, font size, font weight, line height, and padding in the mockup are used for preview and are not converted into JSON style fields, with the actual appearance rendered by Lark's title component and theme

### 4.1 Theme Color

Read the single theme class on `card-header`, and set `header.template` according to the table below
Return a conversion error if there is no theme, more than one theme, or a theme not listed in the table

| Theme class | [`header.template`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/title) |
| --- | --- |
| `theme-default` | `default` |
| `theme-blue` | `blue` |
| `theme-green` | `green` |
| `theme-orange` | `orange` |
| `theme-red` | `red` |
| `theme-grey` | `grey` |

### 4.2 Title Content

| Mockup | Implementation |
| --- | --- |
| `card-title` inside `card-header` | Write the text to [`header.title.content`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/title), and set `header.title.tag` to `plain_text` |
| `card-subtitle` inside `card-header` | Write the text to [`header.subtitle.content`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/title), set `header.subtitle.tag` to `plain_text`, and omit `header.subtitle` if absent |

Each `card-header` must have exactly one `card-title` and at most one `card-subtitle`, and return a conversion error if these counts are not met

## 5 Layout

Corresponds to [Layout](../../doc-design/patterns/lark-card-mockup.md#5-layout) in the mockup

### 5.1 Field Row

Generate one [`column_set`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/containers/column-set) for each `field-row`, with `flex_mode` set to `none` and `horizontal_spacing` set to `12px`
Generate a label column from `field-label`, with `width` set to `64px`
Generate a value column from `field-value`, with `width` set to `weighted` and `weight` set to `1`
Set `horizontal_align` to `left` for both columns, and convert the text font size and color according to [§6](#6-text)

### 5.2 Divider

Convert the HTML `<hr>` into a Lark [`hr`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/divider) component
Set `margin` to `12px 0px 12px 0px`, matching the 12px space above and below the divider in the mockup

### 5.3 Outline Box

Generate one [`interactive_container`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/containers/interactive-container) for each `outlined-block` using the following fixed fields, and populate `elements` with the converted content inside the box

```json
{
  "tag": "interactive_container",
  "has_border": true,
  "border_color": "rgba(223,225,227,1)",
  "corner_radius": "8px",
  "padding": "8px 12px 8px 12px",
  "behaviors": [],
  "elements": []
}
```

**Content and actions inside the box**

If the box contains a details button, place one [`column_set`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/containers/column-set) in `elements`
Set `flex_mode` to `none` and `horizontal_spacing` to `8px`
Set the left column's `width` to `weighted` and `weight` to `1`, and place all block content in it
Set the right column's `width` to `auto` and `vertical_align` to `center`, and place the details button in it

### 5.4 Gray Background Block

Generate one [`interactive_container`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/containers/interactive-container) for each `grey-block` using the following fixed fields, and populate `elements` with the converted content inside the block

```json
{
  "tag": "interactive_container",
  "background_style": "rgba(245,246,247,1)",
  "has_border": false,
  "corner_radius": "4px",
  "padding": "8px 12px 8px 12px",
  "behaviors": [],
  "elements": []
}
```

### 5.5 Action Block

Generate one action block for each `action-block`, and select its colors based on the theme class of `card-header` in its containing `card-mockup`
Generate an outer [`interactive_container`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/containers/interactive-container), with `corner_radius` set to `4px` and `has_border` set to `false`
Set the outer `background_style` to the background color, `padding` to `0px`, and `behaviors` to an empty array
Place one [`column_set`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/containers/column-set) in the outer `elements`, with `flex_mode` set to `none`, `horizontal_spacing` set to `0px`, and two columns inside

Generate `columns` in left-to-right order, with `tag` set to `column` for both columns
Set the left column's `width` to `16px`, `background_style` to the vertical line color, and `elements` to an empty array
Set the right column's `width` to `weighted`, `weight` to `1`, and `background_style` to the background color
Set the right column's `padding` to `8px 12px 8px 12px` and `margin` to `0px 0px 0px -12px`, and populate `elements` with the converted block content
Clipping of the inner vertical line at rounded corners requires client verification

Use the corresponding values from the [official color palette](https://open.feishu.cn/document/feishu-cards/enumerations-for-fields-related-to-color) for color enumerations

| Theme class | Vertical line color | Background color |
| --- | --- | --- |
| `theme-orange` | `orange-350` | `orange-50` |
| `theme-red` | `red-350` | `red-50` |
| `theme-blue` | `blue-350` | `blue-50` |
| `theme-green` | `green-350` | `green-50` |
| `theme-default` | `blue-350` | `blue-50` |
| `theme-grey` | `blue-350` | `blue-50` |

### 5.6 Collapse

Generate one [`collapsible_panel`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/containers/collapsible-panel) for each `<details>`, with `expanded` set to `false`
Convert `<summary>` to `header.title`, set `tag` to `markdown`, and convert the text according to [§6](#6-text)
Convert the remaining child nodes in their original order and place them in `elements`

### 5.7 Table Layout

Use `table-layout` for the table container, `table-header` for the header, and `table-row` for record rows
Read the shared column width definition from `--table-columns` on `table-layout`, and generate a separate [`column_set`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/containers/column-set) for the header and each record row using the same column order
Set `flex_mode` to `none` and `horizontal_spacing` to `8px`
Convert `minmax(0,Nfr)` in the column width definition to `width: weighted` and `weight: N`, where `N` is an integer from 1 to 5
Convert pixel column widths directly to `width`, with values from 16px to 600px, and return a conversion error for other column width definitions
The column width definition in the current example is `minmax(0,1fr) 64px 84px`

**Table header**

Set `padding` to `8px 0px 8px 0px` for each header column
Set `horizontal_align` to `left` for content columns and to `center` for the rightmost action column
Convert each column title to `markdown`, make the text bold, and convert the font size and color according to [§6](#6-text)
Place an [`hr`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/divider) component after the header's `column_set`

**Record rows**

Set `padding` to `8px 0px 8px 0px` for each column in a record row
Set `horizontal_align` to `left` for content columns, and convert their content according to the corresponding component rules
Set both `horizontal_align` and `vertical_align` to `center` for the rightmost action column, and convert buttons according to [§9.1](#91-buttons)
Place an [`hr`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/divider) component after each record's `column_set`

### 5.8 Text Hierarchy Spacing

Corresponds to [Text Hierarchy Spacing](../../doc-design/patterns/lark-card-mockup.md#58-text-hierarchy-spacing) in the mockup

Generate separate `markdown` components for standalone body headings and paragraphs, and do not simulate spacing with blank lines or empty components
Explicitly set `vertical_spacing` to `0px` on the vertical container that arranges these text components, see [JSON 2.0 Structure](https://open.feishu.cn/document/feishu-cards/card-json-v2-structure) for the field
Write each component's `margin` as `Npx 0px 0px 0px` in top, right, bottom, left order, see [Rich Text Component](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/rich-text) for the field

Determine the preceding spacing `N` in the following order, applying only the first matching rule

1. Use `0` for the first text component in the container
2. Use `4` when the current component immediately follows a body heading and is its body text or a subheading with a smaller font size
3. When the current component is the `text-heading` of a new section, use the preceding spacing for the current heading's font size in mockup §5.8
4. Use `8` between adjacent standalone body paragraphs

Retain container padding, and do not add the default spacing of text components or HTML top and bottom margins
Convert the internal layout of field rows, forms, button areas, and other components according to their respective sections
## 6 Text

Corresponds to [Text](../../doc-design/patterns/lark-card-mockup.md#6-text) in the mockup

This chapter converts body text only, convert card titles and subtitles according to [§4](#4-title-bar)

Read the effective font size of the HTML element for body text, including inherited values, and explicitly set `markdown.text_size` according to the table below
Return a conversion error if the font size is not listed in the table

Use the `text-grey` or `text-red` class on the current element or its nearest ancestor for body text color
Return a conversion error if the same element has both classes
If neither the current element nor any ancestor has a color class, do not add a `<font>` color tag, use the default body text color

Read the effective font weight of the HTML element for body text, including inherited values
Accept only `400` and `700` for font weight, return a conversion error for other values

Generate one conversion result from the combined font size, color, and font weight of the same text segment
Write the font size to `markdown.text_size`, and the combined color and font weight to `content`
When both color and bold apply, wrap `**text**` in `<font>`

| Mockup | Implementation |
| --- | --- |
| 30px | Set [`markdown.text_size`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/rich-text) to `heading-0` |
| 24px | Set `text_size` to `heading-1` |
| 20px | Set `text_size` to `heading-2` |
| 18px | Set `text_size` to `heading-3` |
| 16px | Set `text_size` to `heading-4` |
| 14px | Set `text_size` to `normal` |
| 12px | Set [`text_size`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/rich-text) to `notation` |
| `text-grey` | `<font color='grey'>text</font>`, see [Color Enumerations](https://open.feishu.cn/document/feishu-cards/enumerations-for-fields-related-to-color) for values |
| `text-red` | `<font color='red'>text</font>`, see [Color Enumerations](https://open.feishu.cn/document/feishu-cards/enumerations-for-fields-related-to-color) for values |
| Body text with `font-weight:700` | [Bold syntax](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/rich-text) `**text**` |
| Body text with `font-weight:400` | Plain text |
| `text-heading` | Use a separate [`markdown`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/rich-text), map `text_size` from the font size, and use the complete heading text from the mockup in bold for `content` |
| `<code>` | Return a conversion error if the text contains backticks, carriage returns, or line feeds, otherwise wrap the unchanged text in backticks and write it to `markdown.content`, applying only JSON serialization, see [Inline Code Syntax](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/rich-text) |
| Body text `<a>` | Use the text as display text and `href` as the URL, and generate a text link according to [§2.1](#21-text-escaping) |
| Direct child `<li>` of `<ul>` | Use [unordered list syntax](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/rich-text), starting each line with `- ` |
| Direct child `<li>` of `<ol>` | Use [ordered list syntax](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/rich-text), starting each line with incrementing numbers such as `1. ` and `2. ` |
| Nested `<ul>/<ol>` | Use an indentation of 0 for the outermost level, and add 4 spaces for each deeper level |

## 7 Icons and Markers

Corresponds to [Icons and Markers](../../doc-design/patterns/lark-card-mockup.md#7-icons-and-markers) in the mockup

### 7.1 Status Markers

Preserve the status marker characters from the mockup and write them with their associated text to the text component's `content`, escaping text according to [§2.1](#21-text-escaping)

### 7.2 Leading Icons

Generate one [`markdown`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/rich-text) component for each `<img class="row-icon">` and the text on the same line
Resolve relative `src` paths against the directory containing the mockup file
Upload the image using [`image_type: message`](https://open.feishu.cn/document/server-docs/im-v1/image/create), and write the returned `image_key` to `icon.img_key`
Always set `icon.tag` to `custom_icon`
Convert the text on the same line according to [§6](#6-text) and write it to `content`
Do not add size fields to `markdown.icon`, the icon's display behavior as the font size changes requires client verification

## 8 People

Corresponds to [People](../../doc-design/patterns/lark-card-mockup.md#8-people) in the mockup

The app that sends the card must have access to the corresponding user IDs, see [Notes on the Person Component](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/user-profile)

Use `person-capsule` for avatar capsules, with `data-person-key` identifying the corresponding person in the business data
Use this identifier to read the `open_id` for the app that sends the card from the person data defined in the business design, and write it to [`person.user_id`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/user-profile)
Set `size` to `small`, `show_avatar` and `show_name` to `true`, and `style` to `capsule`

For one person, place one `person` in the `elements` of the column corresponding to `field-value`
For multiple people, nest a [`column_set`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/containers/column-set) in the value column, with `flex_mode` set to `flow` and `horizontal_spacing` set to `8px`
Generate one `column` per person, with only that person's `person` in its `elements`

For a `person-capsule` within a sentence, read the corresponding `open_id` using `data-person-key`
Generate a [person tag](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/rich-text) at the original position in the containing `markdown.content`

```html
<person id='actual open_id' show_name=true show_avatar=true style='capsule'></person>
```

Insert the tag as rich text syntax, and escape the surrounding text according to [§2.1](#21-text-escaping)

Use only plain text names for people in titles and buttons

The `person` component and `<person>` tag only display identity and do not send mention notifications
When the business design requires a mention notification, read the `open_id` of the specified recipient and generate a [mention tag](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/rich-text) `<at id='actual open_id'></at>`
If the corresponding `open_id` is unavailable, use the fallback text defined in the business design and convert it to ordinary text according to [§6](#6-text)

## 9 Actions and Inputs

Corresponds to [Actions and Inputs](../../doc-design/patterns/lark-card-mockup.md#9-actions-and-inputs) in the mockup

### 9.1 Buttons

Generate one [`button`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/interactive-components/button) for each `card-button`, which must have exactly one style class
Return a conversion error if the style class is missing or multiple style classes are present

| Style class | `button.type` |
| --- | --- |
| `button-default` | `default` |
| `button-primary` | `primary` |
| `button-danger` | `danger` |

Set `disabled` to `true` for buttons with `is-disabled`, otherwise set it to `false`
Write the complete button text to `text.content`, preserve emoji from the mockup, and always set `text.tag` to `plain_text`
Process text according to the plain text rules in [§2.1](#21-text-escaping)
The disabled state is independent of the style, retain the original `button.type`

Each button must have exactly one of `button-callback` and `button-open-url`, return a conversion error if neither or both are present

Use `button-callback` for callback buttons
`data-action` provides the action identifier, and `data-object-key` specifies the business object
Use `data-object-key` to read the actual object ID from the object data defined in the business design and generate the following structure, with callback parameters following [§2.2](#22-sending-callbacks-and-updates)

```json
{
  "behaviors": [
    {
      "type": "callback",
      "value": {
        "action": "value of data-action",
        "object_id": "actual object ID"
      }
    }
  ]
}
```

Use `<a class="card-button button-open-url …">` for link buttons, with `href` providing the target URL
Validate the URL according to [§2.1](#21-text-escaping) and generate the following interaction

```json
{
  "behaviors": [
    {
      "type": "open_url",
      "default_url": "validated URL"
    }
  ]
}
```

Generate one [`column_set`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/containers/column-set) for each `button-area`
Set `flex_mode` to `flow` and `horizontal_spacing` to `8px`
Generate one `column` per button in mockup order, with only the corresponding button in `elements`

### 9.2 Forms

Use `<form name="form_identifier">` for form mockups
Generate one Lark (Feishu) [`form`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/containers/form-container) for each `<form>`, reading `name` directly from the HTML `name`
Convert child nodes in their original order and place them in `form.elements`
Place the generated `form` directly in `body.elements`
Return a conversion error if the form name is empty or duplicates another form or control name in this card
Read the `name` of every interactive component in the form from `data-field-name`
Return a conversion error if the name is empty or duplicates another form or interactive component name in this card

Use `form-label` for field labels, with `data-field-name` corresponding to the control's `name`
Convert field labels to bold `markdown` according to [§6](#6-text), and place them before their corresponding controls

Set `required` to `true` for controls with `is-required`, otherwise set it to `false`
Convert the red `*` in field labels according to [§6](#6-text), retaining one occurrence

Use `form-submit` for submit buttons, and set `form_action_type` to `submit`
Convert text, styles, and callbacks according to [§9.1](#91-buttons)
Each `form` must contain at least one submit button, otherwise return a conversion error

Use `form-cancel` for cancel buttons
Set [`form_action_type`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/interactive-components/button) to `reset`, and retain the callback parameters for the cancel action
The cancel callback ends the current operation without modifying business data
Whether combining `reset` with a callback triggers cancellation as expected requires client verification

Write the `is-placeholder` text inside a control to that control's [`placeholder.content`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/interactive-components/input), and set `placeholder.tag` to `plain_text`

Do not configure separate callbacks for input and selection controls in a form
On submission, read each field value from [the callback event's `action.form_value`](https://open.feishu.cn/document/feishu-cards/card-callback-communication) using the control's `name`

1. When a submission callback is received, first save its `action.form_value`
2. If submission fails or is returned for revision, read the saved values for that submission and populate each control's initial value field using the control's `name`

**Input Fields**

Use `card-input` for input fields, generate one [`input`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/interactive-components/input) for each element, which must have exactly one type class

| Type class | `input.input_type` |
| --- | --- |
| `input-single` | `text` |
| `input-multiline` | `multiline_text` |

Always set `width` to `fill`, and set `rows` to `2` for multiline input fields
Return a conversion error if the type class is missing or multiple type classes are present
Write the `data-value` of `card-input` to `default_value`
If `data-value` is not provided, set `default_value` to an empty string
Process prefilled values according to the plain text rules in [§2.1](#21-text-escaping)

**Dropdown Selection**

Use `card-select` for dropdown selection, with exactly one type class
Set `width` to `fill` for all four dropdown controls

| Type class | Lark component |
| --- | --- |
| `select-single` | [`select_static`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/interactive-components/single-select-dropdown-menu) |
| `select-multi` | [`multi_select_static`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/interactive-components/multi-select-dropdown-menu) |
| `select-person-single` | [`select_person`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/interactive-components/single-select-user-picker) |
| `select-person-multi` | [`multi_select_person`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/interactive-components/multi-select-user-picker) |

Return a conversion error if the type class is missing or multiple type classes are present

For single-select and multi-select dropdowns, `data-options-key` points to an ordered list of `{label, value}`
Generate the following `options` structure for each item in its original order, see [Standard Dropdown Option Definitions](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/interactive-components/single-select-dropdown-menu) for fields

```json
{
  "text": {
    "tag": "plain_text",
    "content": "value of label"
  },
  "value": "value of value"
}
```

Process text according to the plain text rules in [§2.1](#21-text-escaping)
Return a conversion error if the list is empty, `label` or `value` is missing, or `value` is duplicated

For standard single-select controls, read `data-value`, find the corresponding item in `options.value`, and write its index starting from 1 to [`initial_index`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/interactive-components/single-select-dropdown-menu)
For standard multi-select controls, read the JSON string array in `data-values` and write it to [`selected_values`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/interactive-components/multi-select-dropdown-menu)
If no initial value attribute is provided, omit the corresponding field
Return a conversion error if an initial value is not in the candidate list or the array format is invalid

For person picker controls, `data-options-key` points to the ordered candidate list defined in the business design
Convert each candidate's `open_id` for the app that sends the card to `{"value":"actual open_id"}` in `options`, preserving candidate list order
Return a conversion error if the candidate list is empty or any `open_id` is missing, see [Options Definitions for Person Picker Controls](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/interactive-components/single-select-user-picker) for fields

For single-select person pickers, read the `open_id` corresponding to `data-person-key` and write it to [`initial_option`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/interactive-components/single-select-user-picker)
For multi-select person pickers, read the JSON identifier array in `data-person-keys`, resolve each identifier to an `open_id` string, and write the strings to [`selected_values`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/interactive-components/multi-select-user-picker)
If no initial person identifier is provided, omit the corresponding initial value field
Return a conversion error if a person identifier cannot be resolved or an initial person is not in the candidate list

### 9.3 Date and Time

Generate one [`picker_datetime`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/interactive-components/date-time-picker) for each `card-datetime`, with `width` set to `fill`
Write `data-value` to `initial_datetime` in `yyyy-MM-dd HH:mm` format, the date and time must be valid
If `data-value` is not provided, omit the initial value and read the placeholder according to [§9.2](#92-forms)
Return a conversion error if both the initial value and placeholder are missing

`data-timezone` provides the IANA time zone specified in the business design, see [Notes on the Date and Time Picker](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/interactive-components/date-time-picker) for time zone semantics
Use this time zone both to display the initial value and to interpret the submitted year, month, day, hour, and minute
Display a time zone name that users can understand in the field label
Return a conversion error if the time zone is missing or invalid

## 10 Progress Display

Corresponds to [Progress Display](../../doc-design/patterns/lark-card-mockup.md#10-progress-display) in the mockup

### 10.1 Progress Bar

The progress bar uses `progress-bar`
`data-completed` provides the number of finished items, and `data-total` provides the total number of items
`data-length` provides the number of character bar cells and must be a positive integer
Finished items include successes and failures, the total number of items must be greater than 0, and `0 ≤ finished items ≤ total items`
The number of `█` characters is `floor(finished items × cell count ÷ total items)`, and the remaining cells use `░` to reach the number specified by `data-length`
Parameters must be integers, and invalid parameters return a conversion error

When `data-format` is `ratio`, display “finished items/total items”
When it is `percent`, display `floor(finished items × 100 ÷ total items)%`
When omitted, use `ratio`; other values return a conversion error
The character bar and the count on its right generate one [`markdown`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/rich-text) with `text_size` set to `normal`
Use inline code for the character bar, keep one space between it and the count on its right, and make the count bold

### 10.2 Step Progress

Each direct child of `<ol class="step-progress">` generates one borderless [`column_set`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/containers/column-set)
Set `flex_mode` to `none` and `horizontal_spacing` to `0px`
Set the left column's `width` to `20px` and display sequential numbers starting from 1 in child order
Set the right column's `width` to `weighted` and `weight` to `1`, placing the step name and status first, followed by the details
Generate text components for the step body and details separately according to [§6](#6-text)
Place all step rows in a single-column `column_set` with `flex_mode` set to `none`
Set this column's `width` to `weighted`, `weight` to `1`, and `vertical_spacing` to `0px`
Also set `vertical_spacing` to `0px` for each step's right column
Use the direct child `<div>` of `<li>` as the details and the remaining inline content as the step body
Set `markdown.text_size` to `normal` and `text_align` to `right` for the left column's number, and escape the text according to [§2.1](#21-text-escaping)

## 11 Attachments

Corresponds to [Attachments](../../doc-design/patterns/lark-card-mockup.md#11-attachments) in the mockup

Each `<img class="attachment-thumbnail">` generates one [image component](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/image)
Read and upload the original image according to the corresponding rules in [§7.2](#72-leading-icons), and write the returned `image_key` to `img_key`
Write the HTML `alt` to `alt.content`, using an empty string when omitted

```json
{
  "tag": "img",
  "img_key": "image_key returned by the upload",
  "alt": {
    "tag": "plain_text",
    "content": "HTML alt"
  },
  "size": "56px 56px",
  "scale_type": "crop_center",
  "corner_radius": "6px",
  "preview": true
}
```

Each `attachment-gallery` generates one [`column_set`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/containers/column-set)
Set `flex_mode` to `none` and `horizontal_spacing` to `8px`
In mockup order, each thumbnail generates one column with `width` set to `auto`, and `elements` contains only the corresponding image component

Generate a callback for the “View all” button according to [§9.1](#91-buttons), and read the complete image list through `object_id`
Convert subsequent displays according to the card mockup for the complete set of images provided by the business design, and send and update according to [§2.2](#22-sending-callbacks-and-updates)

File links generate one [`markdown`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/rich-text) component, preserving the 📄 prefix from the mockup
Use the text of `<a>` as the file name and `href` as the link address, escape and validate according to [§2.1](#21-text-escaping), and convert text styles according to [§6](#6-text)

## 12 Implementation Verification

Every card state in the design has a corresponding production rendering path
Express test cases according to [Test Cases](../../doc-design/patterns/testcase.md), citing the design basis for the corresponding state
Tests call the production rendering path and verify the following

- Content and actions match the card mockup and interaction design for that state
- Capacity and pagination meet [§3.2](#32-long-content-and-pagination)

Preview or test-only cards cannot replace verification of production rendering results