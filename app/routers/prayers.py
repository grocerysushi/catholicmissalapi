"""
Prayers endpoints for liturgical prayers and texts.

Note: This module provides access to common prayers and liturgical texts
in accordance with copyright and fair use guidelines.
"""

from fastapi import APIRouter, HTTPException
from typing import List, Optional

from ..models.responses import PrayersResponse
from ..models.liturgical import Prayer

router = APIRouter()


@router.get("/common", response_model=PrayersResponse)
async def get_common_prayers():
    """
    Get common Catholic prayers.
    
    These prayers are in the public domain or used under fair use.
    """
    common_prayers = [
        Prayer(
            name="Our Father",
            category="Lord's Prayer",
            text=(
                "Our Father, who art in heaven, hallowed be thy name; "
                "thy kingdom come; thy will be done on earth as it is in heaven. "
                "Give us this day our daily bread; and forgive us our trespasses "
                "as we forgive those who trespass against us; "
                "and lead us not into temptation, but deliver us from evil. Amen."
            ),
            source="Traditional Catholic Prayer",
            language="en"
        ),
        Prayer(
            name="Hail Mary",
            category="Marian Prayer",
            text=(
                "Hail Mary, full of grace, the Lord is with thee; "
                "blessed art thou among women, and blessed is the fruit of thy womb, Jesus. "
                "Holy Mary, Mother of God, pray for us sinners, "
                "now and at the hour of our death. Amen."
            ),
            source="Traditional Catholic Prayer",
            language="en"
        ),
        Prayer(
            name="Glory Be",
            category="Doxology",
            text=(
                "Glory be to the Father, and to the Son, and to the Holy Spirit. "
                "As it was in the beginning, is now, and ever shall be, "
                "world without end. Amen."
            ),
            source="Traditional Catholic Prayer",
            language="en"
        ),
        Prayer(
            name="Apostles' Creed",
            category="Creed",
            text=(
                "I believe in God, the Father almighty, Creator of heaven and earth, "
                "and in Jesus Christ, his only Son, our Lord, "
                "who was conceived by the Holy Spirit, born of the Virgin Mary, "
                "suffered under Pontius Pilate, was crucified, died and was buried; "
                "he descended into hell; on the third day he rose again from the dead; "
                "he ascended into heaven, and is seated at the right hand of God the Father almighty; "
                "from there he will come to judge the living and the dead. "
                "I believe in the Holy Spirit, the holy catholic Church, "
                "the communion of saints, the forgiveness of sins, "
                "the resurrection of the body, and life everlasting. Amen."
            ),
            source="Traditional Catholic Prayer",
            language="en"
        ),
        Prayer(
            name="Act of Contrition",
            category="Penitential Prayer",
            text=(
                "O my God, I am heartily sorry for having offended Thee, "
                "and I detest all my sins because I dread the loss of heaven and the pains of hell; "
                "but most of all because they offend Thee, my God, "
                "Who art all-good and deserving of all my love. "
                "I firmly resolve, with the help of Thy grace, "
                "to confess my sins, to do penance, and to amend my life. Amen."
            ),
            source="Traditional Catholic Prayer",
            language="en"
        )
    ]
    
    return PrayersResponse(
        prayers=common_prayers,
        source_attribution=(
            "Traditional Catholic prayers in the public domain. "
            "These prayers are part of the common heritage of the Catholic Church."
        )
    )


@router.get("/category/{category}", response_model=PrayersResponse)
async def get_prayers_by_category(category: str):
    """
    Get prayers by category.
    
    Available categories: marian, penitential, eucharistic, seasonal
    """
    category_lower = category.lower()
    
    prayers_by_category = {
        "marian": [
            Prayer(
                name="Hail Mary",
                category="Marian Prayer",
                text=(
                    "Hail Mary, full of grace, the Lord is with thee; "
                    "blessed art thou among women, and blessed is the fruit of thy womb, Jesus. "
                    "Holy Mary, Mother of God, pray for us sinners, "
                    "now and at the hour of our death. Amen."
                ),
                source="Traditional Catholic Prayer",
                language="en"
            ),
            Prayer(
                name="Memorare",
                category="Marian Prayer",
                text=(
                    "Remember, O most gracious Virgin Mary, "
                    "that never was it known that anyone who fled to thy protection, "
                    "implored thy help, or sought thy intercession was left unaided. "
                    "Inspired by this confidence, I fly unto thee, "
                    "O Virgin of virgins, my Mother; "
                    "to thee do I come, before thee I stand, sinful and sorrowful. "
                    "O Mother of the Word Incarnate, "
                    "despise not my petitions, but in thy mercy hear and answer me. Amen."
                ),
                source="Traditional Catholic Prayer - St. Bernard",
                language="en"
            )
        ],
        "penitential": [
            Prayer(
                name="Act of Contrition",
                category="Penitential Prayer",
                text=(
                    "O my God, I am heartily sorry for having offended Thee, "
                    "and I detest all my sins because I dread the loss of heaven and the pains of hell; "
                    "but most of all because they offend Thee, my God, "
                    "Who art all-good and deserving of all my love. "
                    "I firmly resolve, with the help of Thy grace, "
                    "to confess my sins, to do penance, and to amend my life. Amen."
                ),
                source="Traditional Catholic Prayer",
                language="en"
            )
        ],
        "eucharistic": [
            Prayer(
                name="Prayer Before Communion",
                category="Eucharistic Prayer",
                text=(
                    "Lord Jesus Christ, Son of the living God, "
                    "who, by the will of the Father and the work of the Holy Spirit, "
                    "through your Death gave life to the world, "
                    "free me by this, your most holy Body and Blood, "
                    "from all my sins and from every evil; "
                    "keep me always faithful to your commandments, "
                    "and never let me be separated from you."
                ),
                source="Roman Missal",
                language="en",
                copyright_notice="From the Roman Missal - used under fair use"
            )
        ]
    }
    
    if category_lower not in prayers_by_category:
        raise HTTPException(
            status_code=404,
            detail=f"Category '{category}' not found. Available categories: marian, penitential, eucharistic"
        )
    
    return PrayersResponse(
        prayers=prayers_by_category[category_lower],
        source_attribution=(
            f"Catholic prayers in the '{category}' category. "
            "Traditional prayers are in the public domain. "
            "Liturgical texts used under fair use guidelines."
        )
    )


@router.get("/seasonal/{season}", response_model=PrayersResponse)
async def get_seasonal_prayers(season: str):
    """
    Get prayers for liturgical seasons.
    
    Available seasons: advent, christmas, lent, easter
    """
    season_lower = season.lower()
    
    seasonal_prayers = {
        "advent": [
            Prayer(
                name="O Come, O Come Emmanuel (Prayer)",
                category="Advent Prayer",
                text=(
                    "O come, O come, Emmanuel, and ransom captive Israel, "
                    "that mourns in lonely exile here until the Son of God appear. "
                    "Rejoice! Rejoice! Emmanuel shall come to thee, O Israel!"
                ),
                source="Traditional Advent Antiphon",
                language="en"
            )
        ],
        "christmas": [
            Prayer(
                name="Prayer for Christmas",
                category="Christmas Prayer",
                text=(
                    "Almighty God, you have given us your only-begotten Son "
                    "to take our nature upon him and to be born of a pure virgin: "
                    "Grant that we, who have been born again and made your children by adoption and grace, "
                    "may daily be renewed by your Holy Spirit; "
                    "through Jesus Christ our Lord, who lives and reigns with you and the Holy Spirit, "
                    "one God, now and for ever. Amen."
                ),
                source="Traditional Christmas Prayer",
                language="en"
            )
        ],
        "lent": [
            Prayer(
                name="Lenten Prayer",
                category="Lenten Prayer",
                text=(
                    "Almighty and ever living God, "
                    "you invite us deeper into your world, your people, your Lent. "
                    "May this season be for us a time of outward simplicity "
                    "and inward complexity; "
                    "a time of outward fasting and inward feasting; "
                    "a time of outward discipline and inward freedom. "
                    "Help us to walk with Jesus along the way of the cross, "
                    "that we may be found faithful in all things. Amen."
                ),
                source="Traditional Lenten Prayer",
                language="en"
            )
        ],
        "easter": [
            Prayer(
                name="Easter Prayer",
                category="Easter Prayer",
                text=(
                    "God of mercy, we no longer look for Jesus among the dead, "
                    "for he is alive and has become the Lord of life. "
                    "Increase in our minds and hearts "
                    "the risen life we share with Christ "
                    "and help us to grow as your people "
                    "toward the fullness of eternal life with you, "
                    "through Jesus Christ, our Savior and Lord, "
                    "who lives and reigns with you and the Holy Spirit, "
                    "one God, now and forever. Amen."
                ),
                source="Traditional Easter Prayer",
                language="en"
            )
        ]
    }
    
    if season_lower not in seasonal_prayers:
        raise HTTPException(
            status_code=404,
            detail=f"Season '{season}' not found. Available seasons: advent, christmas, lent, easter"
        )
    
    return PrayersResponse(
        prayers=seasonal_prayers[season_lower],
        source_attribution=(
            f"Catholic prayers for the {season} season. "
            "Traditional prayers are in the public domain."
        )
    )