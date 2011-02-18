package CategorySelectorFilter::CMS;

use strict;

sub add_flag {
    my ($cb, $app, $template) = @_;

    my $q = $app->param;
    return if $q->param('_type') eq 'page';

    my $plugin = MT->component("CategorySelectorFilter");
    return if !$plugin->get_config_value('use_plugin', 'blog:'.$app->blog->id);

    my $old = <<HTML;
                <mt:if name="can_edit_categories">
                    <a href="javascript:void(0);" mt:id="[#= item.id #]" mt:command="show-add-category" class="add-category-new-link"><span>Add</span>&nbsp;</a>
                </mt:if>
HTML
    $old = quotemeta($old);

    my $new = <<HTML;
HTML
    $$template =~ s/$old/$new/;

    $old = <<HTML;
                    <label style="width: [#= 165 - (item.path.length * 10) #]px;">
                        <input type="<mt:if name="object_type" eq="page">radio<mt:else>checkbox</mt:if>" name="<mt:if name="object_type" eq="entry">add_</mt:if>category_id<mt:if name="object_type" eq="entry">_[#= item.id #]</mt:if>" class="add-category-checkbox" <mt:if name="category_is_selected">checked="checked"</mt:if> /> [#|h item.label #]
                    </label>
HTML
    $old = quotemeta($old);

    $new = <<HTML;

                [# if ( item.disabled == 1 ) item.disabled = [] #]

                    <label style="width: [#= 165 - (item.path.length * 10) #]px;">
                        <input type="<mt:if name="object_type" eq="page">radio<mt:else>checkbox</mt:if>" name="<mt:if name="object_type" eq="entry">add_</mt:if>category_id<mt:if name="object_type" eq="entry">_[#= item.id #]</mt:if>" class="add-category-checkbox" <mt:if name="category_is_selected">checked="checked"</mt:if> [#= item.disabled #] /> [#|h item.label #]
                    </label>
HTML
    $$template =~ s/$old/$new/;
}

sub add_script {
    my ($cb, $app, $template) = @_;

    my $q = $app->param;
    return if $q->param('_type') eq 'page';

    my $old = <<HTML;
<mt:include name="include/footer.tmpl" id="footer_include">
HTML
    $old = quotemeta($old);

    my $new = <<HTML;
<mt:include name="include/footer.tmpl" id="footer_include">
<style type="text/css">
.list-item2, .list-item3 {
    clear: both;
    margin-bottom: 2px;
    padding: 1px 2px 1px 0;
}
.list-item2 label, .list-item3 label {
    display: inline-block;
    margin-left: 5px;
    overflow: hidden;
    white-space: nowrap;
}
</style>
<script type="text/javascript">
/* <![CDATA[ */
jQuery("#category-selector-list").css('display','none');
jQuery(function() {
    window.onload = function() {
        timerID = setTimeout("setclass()", 1000);
    }
});

function setclass() {
    jQuery("#category-selector-list").css('display','block');
    jQuery("#category-selector-list input[disabled=disabled]").parent().parent().parent().addClass("list-item2");
    jQuery("#category-selector-list input[disabled=disabled]").parent().parent().parent().removeClass("list-item");
}

jQuery(function(){
    jQuery('input.add-category-checkbox').live('change',function(){
        if(jQuery('input.add-category-checkbox:checked').size()){
            jQuery('input.add-category-checkbox').each(function(){
                if(!jQuery(this).attr('checked')){
                    if(!jQuery(this).parent().parent().parent().hasClass("list-item2")){
                        jQuery(this).parent().parent().parent().addClass("list-item3");
                        jQuery(this).parent().parent().parent().removeClass("list-item");
                        jQuery(this).attr('disabled','disabled');
                    }
                }
            });
        } else {
            jQuery('.list-item3 input').attr('disabled','');
            jQuery('.list-item3').addClass("list-item");
            jQuery('.list-item3').removeClass("list-item3");
        }
    });
});
/* ]]> */
</script>
HTML
    $$template =~ s/$old/$new/;

}

sub set_flag {
    my ($cb, $app, $param, $template) = @_;

    my $q = $app->param;
    return if $q->param('_type') eq 'page';

    my $categories = $param->{category_tree};
    return if !$categories;

    my $plugin = MT->component("CategorySelectorFilter");
    return if !$plugin->get_config_value('use_plugin', 'blog:'.$app->blog->id);

    my $cat_ids = $plugin->get_config_value('category_id', 'blog:'.$app->blog->id);
    $cat_ids =~ s/\s//g;
    my @cats = split(/,/, $cat_ids);

    foreach my $category (@$categories) {
        $category->{disabled} = 'disabled="disabled"';
    }

    foreach my $category (@$categories) {
        foreach my $cat_id (@cats) {
            if ($category->{id} == $cat_id) {
                $category->{disabled} = '';
            }
        }
    }
}

1;
